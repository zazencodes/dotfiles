# Neovim Lua Configuration

Quick reference for navigating and understanding this neovim setup.

## 📁 File Structure Overview

```
nvim/
├── init.lua                    # Main entry point (loads all modules)
├── lua/
│   ├── options.lua            # Global vim options & autocmds
│   ├── keymaps.lua            # Global keybindings
│   ├── workflows.lua          # Obsidian-specific workflows & keymaps
│   └── plugins/               # Plugin configurations
│       ├── lazy.lua           # Plugin manager & plugin list
│       ├── lsp.lua            # LSP configuration (mason, lspconfig, cmp)
│       ├── tele.lua           # Telescope fuzzy finder config
│       ├── obsidian.lua       # Obsidian note-taking plugin
│       ├── lualine.lua        # Status line configuration
│       ├── treesitter.lua     # Syntax highlighting config
│       ├── zenmode.lua        # Distraction-free writing mode
│       ├── keymaps.lua        # Plugin-specific keybindings
│       └── options.lua        # Plugin-specific options & theme
├── queries/markdown/          # Custom treesitter queries
│   └── highlights.scm         # Markdown checkbox styling
└── spell/                     # Custom spell files
    ├── en.utf-8.add
    └── en.utf-8.add.spl
```

## ⚙️ Core Configuration Files

### `init.lua`
- Entry point that loads all modules
- VSCode integration check (excludes plugins when in VSCode)
- Load order: options → keymaps → plugins → workflows

### `lua/options.lua`
**Key Settings:**
- Line numbers, relative numbers, spell check enabled
- 4-space tabs (2 for JS/HTML/CSS/Lua, Python uses 79 char limit)
- No swap files, persistent undo in `~/.vim/undodir`
- Auto-remove trailing whitespace on save
- Auto-format Python with Ruff on save
- JSON folding enabled
- Highlight yanked text briefly

### `lua/keymaps.lua`
**Leader Key:** `<Space>`

**Core Bindings:**
- `<leader>w` - Save file
- `<leader>c` - Quit
- `<leader>n/p` - Next/prev buffer
- `<leader>x` - Close buffer
- `<leader>h` - Clear highlights
- `<leader>y/Y` - Yank to clipboard
- `<leader>sr` - Search & replace word under cursor
- `<leader>ig` - Add `# noqa` (Python ignore)
- `<leader>ti` - Toggle checkbox
- Movement: `J/K` in visual mode moves blocks, `<C-u/d>` centers screen

## 🔌 Plugin Configuration

### Plugin Manager: Lazy.nvim (`lua/plugins/lazy.lua`)

**Major Plugin Categories:**

#### Development & LSP
- **Mason + LSP:** Auto-installs `pyright`, `ruff`, `tailwindcss`, `ts_ls`, `eslint`
- **nvim-cmp:** Autocompletion with LSP support
- **Treesitter:** Syntax highlighting for multiple languages
- **Gitsigns:** Git integration with hunk navigation
- **Comment:** Toggle comments with `<leader>/`

#### AI/LLM Integration
- **CodeCompanion:** Anthropic/Claude integration (`<leader>oa`, `<leader>oe`)
- **Avante:** Claude-powered AI assistant with tools
- **MCPHub:** MCP server integration for AI tools
- **Ollama:** Local LLM support

#### File Management & Navigation
- **Telescope:** Fuzzy finding (`<leader>fs`, `<leader>fz`, `<leader>fo`)
- **NvimTree:** File explorer (`<leader>e`)
- **Auto-session:** Session management

#### Note-taking & Documentation
- **Obsidian:** Advanced note-taking with templates
- **Markdown Preview:** Live markdown preview (`<leader>mp`)
- **Zen Mode:** Distraction-free writing (`<leader>zm`)

#### UI & Productivity
- **Lualine:** Customized status line with buffer tabs
- **Alpha:** Custom dashboard with fortune quotes
- **Bufferline:** Enhanced buffer management
- **Catppuccin:** Color scheme (macchiato variant)

### Key Plugin Keymaps (`lua/plugins/keymaps.lua`)

**Telescope:**
- `<leader>fs` - Find files
- `<leader>fp` - Git files
- `<leader>fz` - Live grep
- `<leader>fo` - Recent files
- `<leader>fb` - Buffers

**LSP & Code:**
- `gd` - Go to definition
- `gr` - Go to references
- `<leader>rn` - Rename
- `K` - Hover documentation
- `<leader>gd` - Preview definition

**Tools:**
- `<leader>e` - Toggle file tree
- `<leader>zm` - Zen mode
- `<leader>ic` - Icon picker

## 📝 Obsidian Workflow (`lua/workflows.lua`)

**Vault Path:** `/Users/alex/obsidian/ZazenCodes`

**Workflow Keymaps:**
- `<leader>oo` - Navigate to vault
- `<leader>on` - Apply note template
- `<leader>of` - Format note title
- `<leader>os` - Search vault files
- `<leader>oz` - Live grep vault
- `<leader>ok` - Move file to zettelkasten
- `<leader>odd` - Delete current file

## 🎨 Customizations

### Markdown Enhancements
- Custom treesitter queries for checkbox styling (`queries/markdown/highlights.scm`)
- Conceals markdown syntax for cleaner note appearance
- Custom checkbox icons (󰄱 for unchecked,  for checked)

### Language-Specific Settings
- **Python:** 79-char limit, Ruff formatting on save
- **JavaScript/HTML/CSS/Lua:** 2-space indentation
- **All files:** Trailing whitespace removal on save

### Theme & UI
- Catppuccin Macchiato color scheme
- True color support enabled
- Custom status line with Noice integration
- Buffer tabs in status line

## 🚀 Quick Start Commands

After opening neovim:
1. `<leader>fs` - Find files in project
2. `<leader>e` - Open file explorer
3. `<leader>oo` - Switch to Obsidian vault (if doing notes)
4. `<leader>oa` - Open AI assistant
5. `:Mason` - Manage LSP servers
6. `:Lazy` - Manage plugins

## 🔧 Maintenance

- **Plugin updates:** `:Lazy update`
- **LSP servers:** `:Mason` then `U` to update
- **Treesitter parsers:** `:TSUpdate`
- **Check health:** `:checkhealth`

## 📚 Key Dependencies

Ensure these are installed on your system:
- `ruff` (Python linting/formatting)
- `node` & `npm` (for LSP servers and MCP hub)
- `fortune` (for dashboard quotes)
- Font with nerd icons support (for file tree icons) 
