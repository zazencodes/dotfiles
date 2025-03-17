
-- See `:help telescope` and `:help telescope.setup()`
local actions = require("telescope.actions")
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
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next, -- Scroll down
        ["<C-k>"] = actions.move_selection_previous, -- Scroll up
      },
      n = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      },
    },
  },
}

-- vim.keymap.set("n", "<Leader>sn", "<CMD>lua require('telescope').extensions.notify.notify()<CR>", silent)

