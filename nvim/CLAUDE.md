# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration written in Lua, using [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager.

## Plugin Management

- `:Lazy` — open plugin manager UI
- `:Lazy update` — update all plugins
- `:Mason` — manage LSP servers (press `U` to update all)
- `:TSUpdate` — update Treesitter parsers
- `:checkhealth` — diagnose configuration issues

## Architecture

**Load order** (`init.lua`): `options` → `keymaps` → plugins → `workflows`

- Plugin loading is skipped entirely when running inside VSCode (`vim.g.vscode` check in `init.lua`).
- `lua/options.lua` — global vim settings and all autocmds (formatting, trailing whitespace, JSON folding, etc.)
- `lua/keymaps.lua` — global keybindings; leader key is `<Space>`
- `lua/workflows.lua` — Obsidian note-taking workflows; vault is at `~/obsidian/ZazenCodes`
- `lua/plugins/lazy.lua` — plugin list and inline configs for smaller plugins
- `lua/plugins/lsp.lua` — Mason + nvim-lspconfig + nvim-cmp setup; auto-installs `pyright`, `ruff`, `tailwindcss`, `ts_ls`, `eslint`
- `lua/plugins/keymaps.lua` — plugin-specific keybindings (Telescope, LSP, gitsigns, etc.)
- `lua/plugins/options.lua` — plugin-specific options and theme (Catppuccin macchiato)

## Auto-formatting on Save

- **Python (`.py`):** runs `ruff check --select I --fix` (import sort) then `ruff format` via shell
- **Vue (`.vue`):** runs `node_modules/.bin/prettier % -w`
- **All files (except markdown):** trailing whitespace stripped via `%s/\s\+$//e`

## Language-specific Indent Settings

Set via autocmds in `lua/options.lua`:
- Default: 4-space tabs
- JS/HTML/CSS/Lua: 2-space tabs
- Python: `textwidth=79`, `colorcolumn=79`

## Key Conventions

- New plugin configs go in `lua/plugins/lazy.lua` (inline) or a dedicated file in `lua/plugins/` loaded from `init.lua`.
- Keybindings for plugins belong in `lua/plugins/keymaps.lua`; global bindings in `lua/keymaps.lua`.
- Avante and CodeCompanion configs exist but are commented out in `lua/plugins/lazy.lua`; MCPHub is active.

## System Dependencies

`ruff`, `node`/`npm`, `fortune` (dashboard quotes), and a Nerd Font must be installed on the system.
