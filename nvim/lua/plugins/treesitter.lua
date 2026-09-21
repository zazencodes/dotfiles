-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
local ts = require('nvim-treesitter')

ts.setup {
  install_dir = vim.fn.stdpath('data') .. '/site',
}

-- Ensure language parsers are installed
ts.install {
  'lua', 'python', 'regex', 'bash', 'markdown', 'markdown_inline', 'sql', 'vimdoc', 'javascript',
}

-- Enable treesitter highlighting
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

