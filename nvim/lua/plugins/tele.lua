
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    layout_strategy = "vertical",
    layout_config = {
      preview_height = 0.7,
      vertical = {
        size = {
          width = "95%",
          height = "95%",
        },
      },
    },
  },
}

-- vim.keymap.set("n", "<Leader>sn", "<CMD>lua require('telescope').extensions.notify.notify()<CR>", silent)

