--------------------------------------------------------------------------------
-- Obsidian Workflows (AzathHouse Vault)
--------------------------------------------------------------------------------
--
-- SHELL SHORTCUTS:
-- >>> oo              # Navigate to AzathHouse vault
-- >>> oc              # Jump directly into Areas/SWE/Cheat Sheets
-- >>> on "Note Name"  # Create a new note in AzathHouse/inbox/
--
-- NEOVIM KEYMAPS:
-- <leader>os  -> Telescope search files in AzathHouse
-- <leader>oz  -> Telescope live grep in AzathHouse
-- <leader>oc  -> Telescope search Cheat Sheets (Areas/SWE/Cheat Sheets)
-- <leader>odd -> Delete note in current buffer
--
--------------------------------------------------------------------------------

-- Search files in AzathHouse vault
vim.keymap.set("n", "<leader>os", ":Telescope find_files search_dirs={\"/Users/alex/obsidian/AzathHouse\"}<cr>")
vim.keymap.set("n", "<leader>oz", ":Telescope live_grep search_dirs={\"/Users/alex/obsidian/AzathHouse\"}<cr>")

-- Quick search in SWE Cheat Sheets
vim.keymap.set("n", "<leader>oc", ":Telescope find_files search_dirs={\"/Users/alex/obsidian/AzathHouse/Areas/SWE/Cheat Sheets\"}<cr>")

-- Delete file in current buffer
vim.keymap.set("n", "<leader>odd", ":!rm '%:p'<cr>:bd<cr>")

--------------------------------------------------------------------------------
-- HISTORICAL CONTEXT (2024 ZazenCodes Zettelkasten Workflow):
-- The keymaps below were part of the ZazenCodes YouTube video workflow ("Zettelkasten
-- for programmers"). In that system, notes were staged in zettelkasten/ and organized
-- via regex tag scripts (`og`) into notes/<tag>/.
--
-- Disabled in 2026: Migrated to AzathHouse, where note organization is handled
-- by autonomous coding agents and weekly reviews.
--------------------------------------------------------------------------------
-- Convert note to template and remove leading whitespace (legacy)
-- vim.keymap.set("n", "<leader>on", ":ObsidianTemplate note<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>")
-- Strip date from note title and replace dashes with spaces (legacy)
-- vim.keymap.set("n", "<leader>of", ":s/\\(# \\)[^_]*_/\\1/ | s/-/ /g<cr>")
-- Move file in current buffer to zettelkasten folder (legacy)
-- vim.keymap.set("n", "<leader>ok", ":!mv '%:p' /Users/alex/obsidian/ZazenCodes/zettelkasten<cr>:bd<cr>")
