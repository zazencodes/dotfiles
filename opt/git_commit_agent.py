#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["rich==14.2.0"]
# ///
"""A scrollback-friendly presentation of Codex's JSONL event stream."""

import json
import io
import os
from dataclasses import dataclass
from pathlib import Path
import queue
import re
import shlex
import shutil
import signal
import subprocess
import sys
import tempfile
import threading
import time

from rich import box
from rich.console import Console, Group
from rich.live import Live
from rich.markdown import Markdown
from rich.padding import Padding
from rich.panel import Panel
from rich.spinner import Spinner
from rich.syntax import PygmentsSyntaxTheme, Syntax
from rich.text import Text
from rich.theme import Theme
from rich.table import Table
from pygments.style import Style
from pygments.token import Generic, Text as TokenText

MODEL = "gpt-6-luna"
BASE_PROMPT = "add, commit and push changes"
THEME = Theme({
    "accent": "#79dce8", "muted": "#a2aab8", "success": "#a8db87",
    "warning": "#efc681", "error": "#ff8f9c", "ink": "#e3e8ef",
})
# Terminal control sequences from subprocesses must never control our display.
ANSI = re.compile(r"\x1b(?:\[[0-?]*[ -/]*[@-~]|\][^\x07\x1b]*(?:\x07|\x1b\\))")


class DiffStyle(Style):
    styles = {
        TokenText: "#a2aab8", Generic.Deleted: "#ff8f9c",
        Generic.Inserted: "#a8db87", Generic.Subheading: "#79dce8",
        Generic.Heading: "#a2aab8 bold",
    }


def clean(value):
    return "".join(c for c in ANSI.sub("", str(value)) if c in "\n\t" or (ord(c) >= 32 and ord(c) != 127))


def command_text(command):
    parts = shlex.split(command)
    if len(parts) >= 3 and Path(parts[0]).name in {"bash", "zsh", "sh"} and parts[1] in {"-lc", "-c"}:
        return parts[2]
    return command


def activity(command):
    if re.search(r"\bgit\s+(?:-\S+\s+)*push\b", command):
        return "Pushing to remote"
    if re.search(r"\bgit\s+(?:-\S+\s+)*commit\b", command):
        return "Writing the commit"
    if re.search(r"\bgit\s+(?:-\S+\s+)*(?:diff|status|log|show)\b", command):
        return "Reading the changes"
    return "Running command"


def git(repo, *args, input=None):
    result = subprocess.run(
        ["git", "--no-pager", *args], cwd=repo, input=input,
        capture_output=True, text=True, encoding="utf-8", errors="replace",
    )
    if result.returncode:
        raise RuntimeError(clean(result.stderr.strip()))
    return result.stdout


@dataclass
class FileChange:
    path: str
    added: int | None
    removed: int | None


@dataclass
class Commit:
    oid: str
    short: str
    subject: str
    files: list[FileChange]

    def totals(self):
        return sum(file.added or 0 for file in self.files), sum(file.removed or 0 for file in self.files)


def load_commit(repo, oid):
    full, short, subject = git(repo, "show", "-s", "--format=%H%x00%h%x00%s", oid).rstrip("\n").split("\0", 2)
    stats = git(repo, "show", "--format=", "--numstat", "--no-renames", "--diff-merges=first-parent", "-z", oid)
    files = []
    for record in stats.split("\0"):
        if record:
            added, removed, path = record.split("\t", 2)
            files.append(FileChange(path, None if added == "-" else int(added), None if removed == "-" else int(removed)))
    return Commit(full, short, subject, files)


def new_commits(repo, baseline):
    head = subprocess.run(["git", "rev-parse", "--verify", "--quiet", "HEAD"], cwd=repo, capture_output=True, text=True)
    if head.returncode == 1:  # An initialized repository with no first commit yet.
        return []
    if head.returncode:
        raise RuntimeError(clean(head.stderr.strip()))
    revisions = head.stdout + "".join(f"^{oid}\n" for oid in baseline)
    hashes = git(repo, "rev-list", "--reverse", "--topo-order", "--stdin", input=revisions).splitlines()
    return [load_commit(repo, oid) for oid in hashes]


def commit_view(commit):
    added, removed = commit.totals()
    title = Text.assemble((commit.short, "accent"), "  ", (clean(commit.subject), "bold"))
    title.append(f"\n{len(commit.files)} file{'s' if len(commit.files) != 1 else ''}  ·  ", style="muted")
    title.append(f"+{added:,}", style="success")
    title.append(" / ", style="muted")
    title.append(f"−{removed:,}", style="error")
    files = Table.grid(padding=(0, 2))
    files.add_column(overflow="fold")
    files.add_column(justify="right", no_wrap=True)
    for file in commit.files:
        counts = Text("binary", style="muted") if file.added is None else Text.assemble(
            (f"+{file.added:,}", "success"), "  ", (f"−{file.removed:,}", "error"),
        )
        files.add_row(Text(clean(file.path), style="muted"), counts)
    return Group(title, Padding(files, (1, 0, 0, 2)))


def show_diff(repo, oid, page=False):
    if not re.fullmatch(r"[0-9a-f]{40}|[0-9a-f]{64}", oid):
        raise ValueError("Expected a full Git commit hash")
    commit = load_commit(repo, oid)
    patch = git(repo, "show", "--format=", "--no-ext-diff", "--no-textconv", "--color=never", "--diff-merges=first-parent", oid)
    buffer = io.StringIO() if page else sys.stdout
    width = shutil.get_terminal_size().columns if page else int(os.environ["FZF_PREVIEW_COLUMNS"])
    console = Console(file=buffer, theme=THEME, highlight=False, force_terminal=True, color_system="truecolor", width=max(20, width))
    console.print(commit_view(commit))
    console.print()
    console.print(Syntax(clean(patch), "diff", theme=PygmentsSyntaxTheme(DiffStyle), background_color="default", word_wrap=True))
    if page:
        env = {**os.environ, "LESS": "", "LESSOPEN": "", "LESSCLOSE": ""}
        subprocess.run(["less", "-R", "-+F", "-+X", "-P", "Diff review · arrows / PgUp / PgDn · / search · q back"], input=buffer.getvalue(), text=True, env=env, check=True)


def review_commits(repo, commits):
    # fzf owns /dev/tty; stdin carries only the immutable commit list.
    helper = f"{shlex.quote(sys.executable)} {shlex.quote(str(Path(__file__).resolve()))}"
    rows = []
    for commit in commits:
        added, removed = commit.totals()
        subject = clean(commit.subject).replace("\t", " ").replace("\n", " ")
        rows.append(f"{commit.oid}\t{commit.short}  {subject}  ·  {len(commit.files)} file{'s' if len(commit.files) != 1 else ''}  +{added}/−{removed}")
    env = {**os.environ, "FZF_DEFAULT_OPTS": "", "FZF_DEFAULT_OPTS_FILE": ""}
    result = subprocess.run([
        "fzf", "--ansi", "--no-sort", "--layout=reverse", "--border=rounded",
        "--delimiter=\t", "--with-nth=2..", "--prompt=Commits › ",
        "--border-label= aicommit / review ", "--header-first",
        "--header=↑ ↓ select · Enter expand · Esc close\nDiff: q back · / search\nCtrl-D / Ctrl-U scroll preview",
        "--color=fg:#e3e8ef,bg:-1,hl:#79dce8,fg+:#e3e8ef,bg+:#29323b,hl+:#79dce8,pointer:#a8db87,border:#79dce8,label:#79dce8,header:#a2aab8,prompt:#79dce8,info:#a2aab8",
        f"--preview={helper} --review-diff {{1}}",
        "--preview-window=right,65%,wrap,<55(down,65%,wrap)",
        "--preview-label= commit / diff ",
        f"--bind=enter:execute({helper} --page-diff {{1}}),ctrl-d:preview-page-down,ctrl-u:preview-page-up",
    ], cwd=repo, input="\n".join(rows) + "\n", text=True, stdout=subprocess.DEVNULL, env=env)
    if result.returncode not in (0, 1, 130):
        raise RuntimeError(f"Commit review exited with status {result.returncode}")


class Display:
    def __init__(self, console, repo, prompt):
        self.console = console
        self.started = time.monotonic()
        self.label = "Connecting to Codex"
        self.spinner = Spinner("dots", style="accent")
        self.pending_message = ""
        self.running = {}
        self.commands = 0
        self.usage = {}
        self.completed = False
        self.failed = False
        self.notices = set()
        self.repo = repo
        self.prompt = prompt
        self.active_command = ""
        self.active_output = ""

    def header(self):
        branch = subprocess.run(
            ["git", "branch", "--show-current"], cwd=self.repo, capture_output=True, text=True,
        ).stdout.strip()
        title = Text("aicommit", style="accent")
        title.stylize("bold")
        title.append("  /  ", style="muted")
        title.append(clean(self.repo.name), style="ink")
        if branch:
            title.append(f"  ·  {clean(branch)}", style="muted")
        self.console.print()
        self.console.print(Padding(title, (0, 2)))
        self.console.print(Padding(Text(f"{MODEL}  ·  medium reasoning", style="muted"), (0, 2)))
        self.console.print(Padding(Text(clean(self.prompt), style="ink"), (1, 2, 1, 2)))

    def status(self):
        elapsed = time.monotonic() - self.started
        line = Text.assemble(self.spinner.render(time.monotonic()), "  ", (self.label, "accent"), (f"   {elapsed:.0f}s", "muted"))
        if self.commands:
            line.append(f"  ·  {self.commands} command{'s' if self.commands != 1 else ''}", style="muted")
        rows = [line]
        if self.active_command:
            command = Text(clean(self.active_command), style="muted", overflow="ellipsis", no_wrap=True)
            rows.append(command)
        if self.active_output:
            width = max(16, self.console.width - 6)
            rows.append(Text("\n".join(line[:width] for line in clean(self.active_output).splitlines()[-3:]), style="muted"))
        return Padding(Group(*rows), (0, 2))

    def message(self):
        if self.pending_message:
            self.console.print(Padding(Markdown(clean(self.pending_message)), (0, 2, 1, 4)))
            self.pending_message = ""

    def notice(self, message, fatal=False):
        message = clean(message)
        if message in self.notices:
            return
        self.notices.add(message)
        self.console.print(Padding(Text(message, style="error" if fatal else "warning"), (0, 2, 1, 2)))

    def output(self, output, failed=False):
        lines = clean(output).strip().splitlines()
        if not lines:
            return
        limit = 12 if failed else 6
        # Bound both rows and columns: minified bundles should not consume the pane.
        width = max(16, min(self.console.width - 10, 110))
        clipped = []
        for line in lines[:limit]:
            text = Text(line)
            text.truncate(width, overflow="ellipsis")
            clipped.append(text.plain)
        preview = "\n".join(clipped)
        lexer = "diff" if any(line.startswith(("diff --git", "@@ ")) for line in lines[:6]) else "text"
        content = Syntax(preview, lexer, theme=PygmentsSyntaxTheme(DiffStyle), background_color="default", word_wrap=True) if lexer == "diff" else Text(preview, style="ink" if failed else "muted")
        self.console.print(Padding(content, (0, 6, 0, 4)))
        omitted = len(lines) - limit
        if omitted > 0:
            note = Text(f"… {omitted:,} more lines in session log", style="muted")
            note.stylize("italic")
            self.console.print(Padding(note, (0, 4)))
        self.console.print()

    def event(self, event):
        kind = event["type"]
        if kind == "turn.started":
            self.label = "Studying the working tree"
        elif kind == "turn.completed":
            self.completed = True
            self.usage = event.get("usage", {})
        elif kind in {"error", "turn.failed"}:
            self.failed = kind == "turn.failed" or self.failed
            error = event.get("error", {})
            self.notice(event.get("message") or error.get("message") or json.dumps(event), fatal=kind == "turn.failed")
        elif kind.startswith("item."):
            item = event["item"]
            item_type = item["type"]
            finished = kind == "item.completed"
            if item_type == "agent_message":
                if finished:
                    self.message()
                    self.pending_message = item.get("text", "")
                self.label = "Composing the summary"
            elif item_type == "reasoning":
                self.label = "Thinking through the changes"
            elif item_type == "command_execution":
                command = clean(command_text(item["command"]))
                if kind == "item.started":
                    self.message()
                    self.running[item["id"]] = time.monotonic()
                self.active_command = command
                self.active_output = item.get("aggregated_output", "")
                self.label = activity(command)
                if finished:
                    self.message()
                    self.commands += 1
                    started = self.running.pop(item["id"], None)
                    duration = f"  {time.monotonic() - started:.1f}s" if started is not None else ""
                    failed = item.get("exit_code") != 0
                    line = Text("×  " if failed else "✓  ", style="error" if failed else "success")
                    line.append(command, style="ink")
                    line.highlight_regex(r"\bgit\b", "accent")
                    line.append(f"  exit {item.get('exit_code')}" if failed else duration, style="error" if failed else "muted")
                    self.console.print(Padding(line, (0, 2)))
                    self.output(item.get("aggregated_output", ""), failed)
                    self.active_command = ""
                    self.active_output = ""
                    self.label = "Considering the next step"
            elif item_type == "error" and finished:
                self.notice(item.get("message", "Unknown Codex error"))
            elif item_type in {"mcp_tool_call", "web_search", "file_change", "todo_list"}:
                self.message()
                self.label = {"mcp_tool_call": "Using a tool", "web_search": "Searching", "file_change": "Updating files", "todo_list": "Planning the commit"}[item_type]
                if finished:
                    text = item.get("tool") or item.get("query") or item_type.replace("_", " ")
                    self.console.print(Padding(Text(f"·  {clean(text)}  —  {item.get('status', 'completed')}", style="muted"), (0, 2)))
            elif finished:
                # Keep new event types visible rather than silently dropping them.
                self.console.print(Padding(Text(f"·  {clean(item_type.replace('_', ' '))}", style="muted"), (0, 2)))

    def finish(self, code, log_path, commits=()):
        success = code == 0 and self.completed and not self.failed
        color = "success" if success else "error"
        title = "Session complete" if success else ("Interrupted" if code == 130 else "Session failed")
        content = Markdown(clean(self.pending_message)) if self.pending_message else Text(
            "Codex finished without a summary." if success else "Review the output and session log before retrying.", style="ink",
        )
        elapsed = time.monotonic() - self.started
        footer = Text(f"{elapsed:.1f}s  ·  {self.commands} command{'s' if self.commands != 1 else ''}", style="muted")
        tokens = self.usage.get("input_tokens", 0) + self.usage.get("output_tokens", 0)
        if tokens:
            footer.append(f"  ·  {tokens:,} tokens", style="muted")
        self.console.print()
        panel_title = Text(title, style=color)
        panel_title.stylize("bold")
        sections = [content, Text("")]
        if commits:
            heading = Text(f"{len(commits)} commit{'s' if len(commits) != 1 else ''} created", style="ink")
            heading.stylize("bold")
            sections.extend([heading, Text("")])
            for commit in commits:
                sections.extend([commit_view(commit), Text("")])
        else:
            sections.extend([Text("No commits created during this run.", style="muted"), Text("")])
        sections.append(footer)
        self.console.print(Panel(Group(*sections), title=panel_title, title_align="left", border_style=color, box=box.ROUNDED, padding=(1, 2), width=min(self.console.width, 100)))
        log_link = Text(str(log_path), style="muted")
        log_link.stylize(f"underline link {log_path.as_uri()}")
        self.console.print(Text.assemble(("  Full log  ", "muted"), log_link), soft_wrap=True)
        self.console.print()
        return 0 if success else (code or 1)


def read_stream(stream, channel, events):
    try:
        for line in stream:
            events.put((channel, line))
    finally:
        stream.close()
        events.put((channel, None))


def stop_process(process):
    if process.poll() is None:
        os.killpg(process.pid, signal.SIGTERM)
        try:
            process.wait(timeout=3)
        except subprocess.TimeoutExpired:
            os.killpg(process.pid, signal.SIGKILL)
            process.wait()


def run(prompt):
    console = Console(theme=THEME, highlight=False)
    display = Display(console, Path.cwd(), prompt)
    display.header()
    # Private logs retain complete commands, output, diagnostics and event data.
    log = tempfile.NamedTemporaryFile(mode="w", prefix="aicommit-", suffix=".jsonl", delete=False)
    log_path = Path(log.name)
    process = None
    code = 1
    baseline = None
    interactive = sys.stdin.isatty() and sys.stdout.isatty()
    try:
        if interactive:
            for program in ("fzf", "less"):
                if not shutil.which(program):
                    raise RuntimeError(f"{program} is required for interactive commit review")
        # Exclude pre-existing branches, tags, detached HEAD and reflog history.
        baseline = git(display.repo, "rev-list", "--all", "--reflog", "--no-walk").splitlines()
        with log, Live(console=console, transient=True, refresh_per_second=10) as live:
            process = subprocess.Popen(
                ["codex", "exec", "--json", "--cd", str(Path.cwd()),
                 "--dangerously-bypass-approvals-and-sandbox", "-m", MODEL,
                 "-c", "model_reasoning_effort=medium", prompt],
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
                encoding="utf-8", errors="replace", start_new_session=True,
            )
            events = queue.Queue()
            for channel, stream in (("stdout", process.stdout), ("stderr", process.stderr)):
                threading.Thread(target=read_stream, args=(stream, channel, events), daemon=True).start()
            closed = 0
            live.update(display.status())
            while closed < 2:
                try:
                    channel, line = events.get(timeout=0.1)
                except queue.Empty:
                    live.update(display.status())
                    continue
                if line is None:
                    closed += 1
                    continue
                if channel == "stdout":
                    log.write(line)
                    log.flush()
                    display.event(json.loads(line))
                else:
                    log.write(json.dumps({"type": "diagnostic", "message": line.rstrip()}) + "\n")
                    log.flush()
                    display.notice(line.rstrip())
                live.update(display.status())
            code = process.wait()
    except KeyboardInterrupt:
        code = 130
        display.notice("Stopping Codex…")
    except (OSError, ValueError, KeyError, RuntimeError) as error:
        display.failed = True
        display.notice(f"aicommit: {error}", fatal=True)
    finally:
        if process is not None:
            stop_process(process)
        log.close()
    commits = []
    if baseline is not None:
        try:
            commits = new_commits(display.repo, baseline)
        except (OSError, ValueError, RuntimeError) as error:
            display.failed = True
            display.notice(f"Could not read commits: {error}", fatal=True)
    result = display.finish(code, log_path, commits)
    if interactive and commits and code != 130:
        try:
            review_commits(display.repo, commits)
        except KeyboardInterrupt:
            pass  # The Git work is complete; closing review leaves its status intact.
        except (OSError, RuntimeError) as error:
            display.notice(f"Could not open commit review: {error}", fatal=True)
            return result or 1
    return result


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] in {"--review-diff", "--page-diff"}:
        try:
            show_diff(Path.cwd(), sys.argv[2], page=sys.argv[1] == "--page-diff")
        except KeyboardInterrupt:
            sys.exit(130)
        except (OSError, RuntimeError, ValueError, subprocess.CalledProcessError) as error:
            print(f"Cannot show diff: {error}", file=sys.stderr)
            sys.exit(1)
        sys.exit(0)
    if sys.argv[1:2] in (["-h"], ["--help"], ["help"]):
        print("Usage: aicommit [custom instructions...]\n\nStages, commits, and pushes using Codex with a live activity feed.\nNew commits open in interactive review: Enter expands, q returns, Esc closes.\nCustom instructions are appended to: add, commit and push changes")
        sys.exit(0)
    instructions = " ".join(sys.argv[1:])
    sys.exit(run(f"{BASE_PROMPT}. {instructions}" if instructions else BASE_PROMPT))
