"""Run with: uv run --with rich==14.2.0 python -m unittest discover -s tests"""

import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import time
import unittest


ROOT = Path(__file__).resolve().parents[1]
RUNNER = ROOT / "opt/git_commit_agent.py"


class AicommitIntegrationTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.folder = Path(self.directory.name)
        self.fake = self.folder / "codex"
        self.env = {**os.environ, "PATH": f"{self.folder}:{os.environ['PATH']}", "NO_COLOR": "1"}

    def fake_codex(self, source):
        self.fake.write_text(f"#!{sys.executable}\n" + source)
        self.fake.chmod(0o755)

    def run_agent(self, *args):
        result = subprocess.run([sys.executable, str(RUNNER), *args], cwd=ROOT, env=self.env,
                                capture_output=True, text=True, timeout=10)
        # Logs are deliberately retained by the product; remove test-only logs.
        for line in result.stdout.splitlines():
            if "Full log" in line:
                Path(line.split("Full log", 1)[1].strip()).unlink(missing_ok=True)
        return result

    def test_success_preserves_prompt_and_folds_long_output(self):
        argv_path = self.folder / "argv.json"
        events = [
            {"type": "turn.started"},
            {"type": "item.started", "item": {"id": "cmd", "type": "command_execution", "command": "/bin/zsh -lc 'git diff'"}},
            {"type": "item.completed", "item": {"id": "cmd", "type": "command_execution", "command": "/bin/zsh -lc 'git diff'", "exit_code": 0, "aggregated_output": "\n".join(f"row {i}" for i in range(50))}},
            {"type": "item.completed", "item": {"id": "msg", "type": "agent_message", "text": "Done: `abc1234`."}},
            {"type": "turn.completed", "usage": {"input_tokens": 900, "output_tokens": 100}},
        ]
        self.fake_codex(f"import json, sys\nfrom pathlib import Path\nPath({str(argv_path)!r}).write_text(json.dumps(sys.argv))\nfor event in {events!r}:\n print(json.dumps(event), flush=True)\n")
        result = self.run_agent("do not push", "split commits")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Session complete", result.stdout)
        self.assertIn("44 more lines", result.stdout)
        self.assertNotIn("row 49", result.stdout)
        self.assertIn("abc1234", result.stdout)
        self.assertNotIn("\x1b", result.stdout)
        argv = json.loads(argv_path.read_text())
        self.assertEqual(argv[-1], "add, commit and push changes. do not push split commits")
        self.assertIn("--dangerously-bypass-approvals-and-sandbox", argv)
        self.assertIn("--json", argv)

    def test_failure_keeps_exit_code_and_diagnostics(self):
        self.fake_codex("import sys\nprint('authentication expired', file=sys.stderr)\nsys.exit(7)\n")
        result = self.run_agent()
        self.assertEqual(result.returncode, 7)
        self.assertIn("authentication expired", result.stdout)
        self.assertIn("Session failed", result.stdout)

    def test_help_never_starts_codex(self):
        marker = self.folder / "called"
        self.fake_codex(f"from pathlib import Path\nPath({str(marker)!r}).touch()\n")
        for flag in ("-h", "--help", "help"):
            result = self.run_agent(flag)
            self.assertEqual(result.returncode, 0)
            self.assertIn("Usage:", result.stdout)
            self.assertFalse(marker.exists())

    def test_invalid_stream_stops_process_and_reports_error(self):
        self.fake_codex("import time\nprint('not JSON', flush=True)\ntime.sleep(60)\n")
        result = self.run_agent()
        self.assertEqual(result.returncode, 1)
        self.assertIn("Session failed", result.stdout)
        self.assertIn("aicommit:", result.stdout)

    def test_completion_is_required_even_with_zero_exit_code(self):
        self.fake_codex("pass\n")
        result = self.run_agent()
        self.assertEqual(result.returncode, 1)
        self.assertIn("Session failed", result.stdout)

    def test_turn_failure_is_not_relabelled_as_success(self):
        self.fake_codex("import json\nprint(json.dumps({'type':'turn.failed', 'error':{'message':'connection lost'}}))\n")
        result = self.run_agent()
        self.assertEqual(result.returncode, 1)
        self.assertIn("connection lost", result.stdout)
        self.assertIn("Session failed", result.stdout)

    def test_interrupt_terminates_codex(self):
        ready = self.folder / "ready"
        self.fake_codex(f"import os, time\nfrom pathlib import Path\nPath({str(ready)!r}).write_text(str(os.getpid()))\ntime.sleep(60)\n")
        process = subprocess.Popen([sys.executable, str(RUNNER)], cwd=ROOT, env=self.env,
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        self.addCleanup(lambda: process.kill() if process.poll() is None else None)
        deadline = time.monotonic() + 5
        while not ready.exists() and time.monotonic() < deadline:
            time.sleep(.02)
        self.assertTrue(ready.exists())
        process.send_signal(signal.SIGINT)
        stdout, stderr = process.communicate(timeout=6)
        self.assertEqual(process.returncode, 130, stderr)
        self.assertIn("Interrupted", stdout)
        with self.assertRaises(ProcessLookupError):
            os.kill(int(ready.read_text()), 0)
        for line in stdout.splitlines():
            if "Full log" in line:
                Path(line.split("Full log", 1)[1].strip()).unlink(missing_ok=True)


class CommitReviewTests(unittest.TestCase):
    def setUp(self):
        import importlib.util
        spec = importlib.util.spec_from_file_location("aicommit_review", RUNNER)
        self.module = importlib.util.module_from_spec(spec)
        sys.modules[spec.name] = self.module
        spec.loader.exec_module(self.module)
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.repo = Path(self.directory.name)
        self.git("init", "-b", "main")

    def git(self, *args, input=None):
        return self.module.git(self.repo, *args, input=input).strip()

    def baseline(self):
        return self.git("rev-list", "--all", "--reflog", "--no-walk").splitlines()

    def commit(self, subject, parent=None):
        self.git("add", "--", ".")
        self.git("diff", "--cached", "--check")
        self.git("diff", "--cached")
        tree = self.git("write-tree")
        args = ["commit-tree", tree, "-m", subject]
        if parent:
            args.extend(["-p", parent])
        oid = self.git(*args)
        self.git("update-ref", "refs/heads/main", oid)
        return oid

    def test_root_and_multiple_commits_with_exact_file_counts(self):
        before = self.baseline()
        (self.repo / "first.txt").write_text("one\ntwo\n")
        first = self.commit("Add first file")
        (self.repo / "second.txt").write_text("three\n")
        second = self.commit("Add second file", first)
        commits = self.module.new_commits(self.repo, before)
        self.assertEqual([commit.oid for commit in commits], [first, second])
        self.assertEqual([commit.totals() for commit in commits], [(2, 0), (1, 0)])
        self.assertEqual(commits[0].files[0].path, "first.txt")
        self.assertEqual(self.module.new_commits(self.repo, self.baseline()), [])

    def test_preexisting_commits_are_excluded_after_branch_switch(self):
        (self.repo / "file.txt").write_text("old\n")
        first = self.commit("Add file")
        (self.repo / "file.txt").write_text("existing branch\n")
        second = self.commit("Change file", first)
        self.git("branch", "existing", second)
        self.git("reset", "--hard", first)
        before = self.baseline()
        self.git("checkout", "existing")
        self.assertEqual(self.module.new_commits(self.repo, before), [])

    def test_amended_commit_and_binary_and_unusual_paths(self):
        (self.repo / "file.txt").write_text("old\n")
        first = self.commit("Add file")
        before = self.baseline()
        (self.repo / "file.txt").write_text("amended\n")
        (self.repo / "binary.dat").write_bytes(b"\0\1\2")
        (self.repo / "odd\tname\ntext.txt").write_text("new\n")
        amended = self.commit("Add amended files")
        commits = self.module.new_commits(self.repo, before)
        self.assertEqual([commit.oid for commit in commits], [amended])
        self.assertNotEqual(amended, first)
        self.assertEqual(commits[0].totals(), (2, 0))
        files = {file.path: file for file in commits[0].files}
        self.assertIsNone(files["binary.dat"].added)
        self.assertIn("odd\tname\ntext.txt", files)

    def test_final_summary_is_grounded_in_git(self):
        import io
        from rich.console import Console
        (self.repo / "file.txt").write_text("one\ntwo\n")
        before = self.baseline()
        oid = self.commit("Add readable files")
        commits = self.module.new_commits(self.repo, before)
        stream = io.StringIO()
        display = self.module.Display(Console(file=stream, theme=self.module.THEME, width=100), self.repo, "test")
        display.completed = True
        display.pending_message = "Done."
        display.finish(0, self.repo / "log.jsonl", commits)
        output = stream.getvalue()
        for expected in (oid[:7], "Add readable files", "1 commit created", "file.txt", "+2", "−0"):
            self.assertIn(expected, output)

    def test_diff_helper_displays_complete_patch_without_codex(self):
        (self.repo / "file.txt").write_text("\n".join(f"line {i}" for i in range(80)) + "\n")
        oid = self.commit("Add long file")
        result = subprocess.run([sys.executable, str(RUNNER), "--review-diff", oid], cwd=self.repo,
                                env={**os.environ, "FZF_PREVIEW_COLUMNS": "90", "NO_COLOR": "1"},
                                capture_output=True, text=True, timeout=5)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("+line 79", result.stdout)
        self.assertIn("Add long file", result.stdout)

    def test_review_cancellation_preserves_completed_work(self):
        from unittest.mock import patch
        (self.repo / "file.txt").write_text("one\n")
        oid = self.commit("Add file")
        commit = self.module.load_commit(self.repo, oid)
        with patch.object(self.module.subprocess, "run", return_value=subprocess.CompletedProcess([], 130)) as run:
            self.module.review_commits(self.repo, [commit])
        argv = run.call_args.args[0]
        self.assertIn("--with-nth=2..", argv)
        self.assertTrue(any("--page-diff {1}" in arg for arg in argv))
        self.assertIn(oid, run.call_args.kwargs["input"])

    def test_failed_push_still_reports_created_commit_without_opening_review_in_pipe(self):
        tools = self.repo / "tools"
        tools.mkdir()
        fake = tools / "codex"
        fake.write_text(f"#!{sys.executable}\n" + '''import json, subprocess, sys
from pathlib import Path
def git(*args):
    return subprocess.run(['git', *args], capture_output=True, text=True, check=True).stdout.strip()
Path('result.txt').write_text('created during this run\\n')
git('add', '--', 'result.txt')
git('diff', '--cached', '--check')
git('diff', '--cached')
tree = git('write-tree')
oid = git('commit-tree', tree, '-m', 'Add fixture result')
git('update-ref', 'refs/heads/main', oid)
print(json.dumps({'type':'turn.failed', 'error':{'message':'Push failed'}}), flush=True)
sys.exit(7)
''')
        fake.chmod(0o755)
        fake_fzf = tools / "fzf"
        fake_fzf.write_text(f"#!{sys.executable}\nfrom pathlib import Path\nPath('review-started').touch()\n")
        fake_fzf.chmod(0o755)
        result = subprocess.run([sys.executable, str(RUNNER)], cwd=self.repo,
                                env={**os.environ, "PATH": f"{tools}:{os.environ['PATH']}", "NO_COLOR": "1"},
                                capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, 7, result.stderr)
        self.assertIn("Session failed", result.stdout)
        self.assertIn("Add fixture result", result.stdout)
        self.assertIn("result.txt", result.stdout)
        self.assertIn(self.git('rev-parse', '--short', 'HEAD'), result.stdout)
        self.assertFalse((self.repo / 'review-started').exists())
        for line in result.stdout.splitlines():
            if "Full log" in line:
                Path(line.split("Full log", 1)[1].strip()).unlink(missing_ok=True)


if __name__ == "__main__":
    unittest.main()
