vim.cmd("colorscheme catppuccin-macchiato") -- set color theme

vim.g.startify_custom_header = "" -- startify remove random quote

vim.opt.termguicolors = true --bufferline
require("bufferline").setup{} --bufferline

vim.o.conceallevel = 2 -- set conceal level for obsidian plugin


-- codecompanion.nvim
vim.keymap.set({ "n", "v" }, "<leader>oa", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader>oe", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })
vim.cmd([[cab cc CodeCompanion]]) -- Expand 'cc' into 'CodeCompanion' in the command line


