-- telescope
vim.keymap.set("n", "<leader>fs", ":Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fp", ":Telescope git_files<cr>")
vim.keymap.set("n", "<leader>fz", ":Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fo", ":Telescope oldfiles<cr>")
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<cr>")
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<cr>")

-- tree
vim.keymap.set("n", "<leader>e", ":NvimTreeFindFileToggle<cr>")

-- twilight
-- vim.keymap.set("n", "<leader>tw", ":Twilight<cr>")

-- zen mode
vim.keymap.set("n", "<leader>zm", ":ZenMode<cr>")

-- format code using LSP
-- vim.keymap.set("n", "<leader>pp", vim.lsp.buf.format)

-- markdown preview
vim.keymap.set("n", "<leader>mp", ":MarkdownPreviewToggle<cr>")

-- nvim-comment
vim.keymap.set({"n", "v"}, "<leader>/", ":CommentToggle<cr>")

-- spider
-- vim.keymap.set({ "n", "o", "x" }, "<leader>w", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Spider-w" })
-- vim.keymap.set({ "n", "o", "x" }, "<leader>e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "Spider-e" })
-- vim.keymap.set({ "n", "o", "x" }, "<leader>b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Spider-b" })

------------------
-- goto-preview --
------------------
--
-- note: lsp config (from lsp.lua)
-- nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
-- nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
-- nmap('gt', vim.lsp.buf.type_definition, 'Type [D]efinition')
-- nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
--
vim.keymap.set('n', '<leader>gd', ":lua require('goto-preview').goto_preview_definition()<CR>")
vim.keymap.set('n', '<leader>gt', ":lua require('goto-preview').goto_preview_type_definition()<CR>")
vim.keymap.set('n', '<leader>gi', ":lua require('goto-preview').goto_preview_implementation()<CR>")
vim.keymap.set('n', '<leader>gp', ":lua require('goto-preview').close_all_win()<CR>")

--------------
-- obsidian --
--------------
--
-- shell workflow
-- >>> # navigate to vault (optional)
-- >>> oo
--
-- >>> # call my "obsidian new note" shell script (~/bin/on)
-- >>> on "Note Name"
--
-- ))) # inside vim now, format note as template
-- ))) <leader>on
-- ))) # add tag, e.g. fact / blog / video / etc..
-- ))) # add hubs, e.g. [[hubs/python]], [[hubs/machine-learning]], etc...
--
-- >>> # review notes in inbox
-- >>> or
--
-- ))) # inside vim now, move to zettelkasten
-- ))) <leader>ok
-- ))) # or delete
-- ))) <leader>odd
--
-- navigate to vault
vim.keymap.set("n", "<leader>oo", ":cd /Users/alex/library/Mobile\\ Documents/iCloud~md~obsidian/Documents/ZazenCodes<cr>")
--
-- convert note to template and remove leading white space
vim.keymap.set("n", "<leader>on", ":ObsidianTemplate fact<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>")
-- strip date from note title and replace dashes with spaces
-- must have cursor on title
vim.keymap.set("n", "<leader>of", ":s/\\(# \\)[^_]*_/\\1/ | s/-/ /g<cr>")
--
-- search for files in full vault
vim.keymap.set("n", "<leader>os", ":Telescope find_files search_dirs={\"/Users/alex/library/Mobile\\ Documents/iCloud~md~obsidian/Documents/ZazenCodes\"}<cr>")
vim.keymap.set("n", "<leader>oz", ":Telescope live_grep search_dirs={\"/Users/alex/library/Mobile\\ Documents/iCloud~md~obsidian/Documents/ZazenCodes\"}<cr>")
--
-- search for files in notes (ignore zettelkasten)
vim.keymap.set("n", "<leader>ois", ":Telescope find_files search_dirs={\"/Users/alex/library/Mobile\\ Documents/iCloud~md~obsidian/Documents/ZazenCodes/notes\"}<cr>")
vim.keymap.set("n", "<leader>oiz", ":Telescope live_grep search_dirs={\"/Users/alex/library/Mobile\\ Documents/iCloud~md~obsidian/Documents/ZazenCodes/notes\"}<cr>")
--
-- move file in current buffer to zettelkasten folder
vim.keymap.set("n", "<leader>ok", ":!mv '%:p' /Users/alex/library/Mobile\\ Documents/iCloud~md~obsidian/Documents/ZazenCodes/zettelkasten<cr>:bd<cr>")
-- delete file in current buffer
vim.keymap.set("n", "<leader>odd", ":!rm '%:p'<cr>:bd<cr>")

