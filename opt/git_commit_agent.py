#!/Users/alex/virtualenvs/adhoc/bin/python
# PyPI Dependencies: langchain langgraph langchain-ollama langchain-mcp-adapters
import argparse
import asyncio
import subprocess
import sys

from langchain.agents import create_agent
from langchain_core.globals import set_debug, set_verbose
from langchain_core.messages import AIMessage, ToolMessage
from langchain_mcp_adapters.client import MultiServerMCPClient
from langchain_ollama import ChatOllama

# set_debug(True)
# set_verbose(True)

SYSTEM_PROMPT = """
You are a git commit assistant. Your task is to use your tools to inspect the
provided git repository and commit the changes. You should group files into
cohesive subsets and commit them in batches. Your commit messages should be
short but suitably related to the content of the files that have been changed.
"""


async def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("--repo", required=True, help="Path to the git repository")
    p.add_argument(
        "--model",
        default="gpt-oss:20b",
        help="Ollama model name (must support tool calling)",
    )
    p.add_argument(
        "--push",
        action="store_true",
        help="After committing, run `git push` in the repo (pushes to the default upstream)",
    )
    args = p.parse_args()

    client = MultiServerMCPClient(
        {
            "git": {
                "transport": "stdio",
                "command": "uvx",
                "args": ["mcp-server-git", "--repository", args.repo],
            }
        }
    )

    tools = await client.get_tools(server_name="git")

    llm = ChatOllama(model=args.model)
    agent = create_agent(llm, tools=tools, system_prompt=SYSTEM_PROMPT)

    task = f"Check status then stage and commit changes in: {args.repo}"

    print(f"--- Starting Agent: {args.model} ---")

    async for event in agent.astream_events(
        {"messages": [("user", task)]}, version="v2", config={"recursion_limit": 200}
    ):
        kind = event["event"]

        # 1. STREAMING TEXT (LLM Thinking/Talking)
        if kind == "on_chat_model_stream":
            content = event["data"]["chunk"].content
            if content:
                print(content, end="", flush=True)

        # 2. CLEAN TOOL CALLS
        elif kind == "on_tool_start":
            # Filter out the 'runtime' and 'repo_path' to keep it tidy
            tool_input = event["data"].get("input", {})
            clean_args = {
                k: v for k, v in tool_input.items() if k not in ["runtime", "repo_path"]
            }

            print(f"🛠️  [TOOL]: {event['name']}")
            if clean_args:
                print(f"   Args: {clean_args}")

        # 3. CLEAN TOOL RESULTS
        elif kind == "on_tool_end":
            output = event["data"].get("output")

            # Extract just the 'text' part if it's a list of dicts (common in MCP)
            if isinstance(output, list) and len(output) > 0 and "text" in output[0]:
                result_text = output[0]["text"]
            else:
                result_text = str(output)

            print(f"📝 [RESULT]: {result_text.strip()}")
            print("-" * 40)

    if args.push:
        print("\n🚀 Pushing commits (`git push`)...")
        try:
            subprocess.run(["git", "-C", args.repo, "push"], check=True)
            print("✅ Push complete.")
        except subprocess.CalledProcessError as e:
            print(f"❌ Push failed (exit {e.returncode}).", file=sys.stderr)
            raise


if __name__ == "__main__":
    asyncio.run(main())
