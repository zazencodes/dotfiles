# Dotfiles Repository

This repository stores configuration files centrally and symlinks them to their appropriate locations on the target macOS system. 

## Agent Guidelines

- Any edits made to the configurations in this repository should adhere to the existing formatting and structure where appropriate.
- When adding new scripts to `bin` or `opt`, remind the user to run the symlinking script afterwards.

### Documentation

- **`README.md`**: Keep minimal. Update ONLY to sync setup commands (e.g., symlinks); avoid adding general documentation here.
- **`AGENTS.md`**: Keep this file in sync as well.

## High-Level Architecture

- **Standalone Configurations:** Configurations like `.zshrc`, `.tmux.conf`, and `.gitconfig` sit at the root and track directly to `~`.
- **Directory Configurations:** Configurations like `nvim/`, `ghostty/` and `alacritty/` track to `~/.config/`.
- **Scripts and Binaries:** Small executable scripts live in `bin/` (symlinked to `~/bin`), while utility libraries or python scripts live in `opt/` (symlinked to `~/opt`).
- **Symlinking Script:** `symlink_dotfiles.sh` is a helper script used to run automated symlinking of directories like `bin` and `opt`.

## Component Overview

### Shell and Terminal Multiplexing
- **`.zshrc`**: The primary Zsh shell configuration, handling aliases, environment variables, initialization of tools, and loading credentials.
  - Baseline secrets are loaded globally from `~/.secrets/global.sh`.
  - On-demand provider API keys (`openai`, `anthropic`, `gemini`, `opencode`) live in `~/.secrets/` and are toggled via `load-<provider>` and `clear-<provider>` aliases, or scoped to a single command via `with-secrets VAR1 [VAR2...] -- <cmd>` (e.g. `pi` is wrapped with `with-secrets OPENCODE_API_KEY -- pi`).
- **`.p10k.zsh`**: Powerlevel10k theme configuration for styling the Zsh prompt.
- **`.tmux.conf`**: Configuration for tmux, optimizing keybinds, status bar aesthetics, and plugins.
- **`ghostty/`**: Configuration for the Ghostty terminal emulator (specifically `config`).
  - Cursor shaders live in `ghostty/shaders/`.
  - To turn cursor shaders **ON**, ensure these lines are present and uncommented in `ghostty/config`:
    - `custom-shader = shaders/cursor_warp.glsl`
    - `custom-shader = shaders/ripple_cursor.glsl`
    - `custom-shader-animation = always`
  - To turn cursor shaders **OFF**, comment out or remove those three lines from `ghostty/config`; do not delete the shader files.
  - After changing shader state, validate with `ghostty +validate-config --config-file=ghostty/config` and reload/restart Ghostty.
- **`alacritty/`**: Configuration for the Alacritty GPU-accelerated terminal emulator (specifically `alacritty.toml`).

### macOS Environment & Automation
- **`.aerospace.toml`**: Settings for AeroSpace, a macOS tiling window manager. This controls window layouts and keyboard-driven window management.
- **`hammerspoon/`**: Contains Lua scripts (`init.lua`) for Hammerspoon, a powerful macOS desktop automation tool.
- **`karabiner-elements/`**: JSON configuration (`karabiner.json`) for advanced keyboard remapping via Karabiner-Elements.

### Editor
- **`nvim/`**: A fully-featured Neovim setup. It includes a `lazy-lock.json` file indicating the use of the `lazy.nvim` plugin manager, along with `lua/`, `queries/`, and `spell/` directories for extensive customization.

### Custom Scripts (`bin/` and `opt/`)
The `bin/` directory contains helper shell scripts meant to be placed in the user's `$PATH`.
- **`on` & `og`**: Scripts built specifically to automate creating and moving notes directly into the user's Obsidian (`ZazenCodes`) vault.
- **`aicommit`**: A bash wrapper script that simply executes a python AI tool for generating git commits.
- **`opt/git_commit_agent.py`**: The underlying Python script invoked by `aicommit`.
- **`compress_video`**: A bash utility that compresses video files to land below a requested size cap, with optional width reduction.
- **`rip_transcript`**: A bash wrapper that transcribes audio or video files and writes transcript artifacts next to the source media.
- **`opt/rip_transcript.py`**: The underlying Python script invoked by `rip_transcript`, using `mlx_whisper` to generate plain text, timestamped text, and raw JSON outputs.

### AI Tooling
- **`llm/`**: Contains prompt templates intended to be symlinked to `~/Library/Application Support/io.datasette.llm`, configuring the LLM CLI tool.
