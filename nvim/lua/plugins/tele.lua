
-- See `:help telescope` and `:help telescope.setup()`
local actions = require("telescope.actions")

local open_all = function(prompt_bufnr)
  actions.smart_send_to_qflist(prompt_bufnr)
  vim.cmd("cfdo edit")
  vim.cmd("cclose")
end

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
        ["<C-o>"] = open_all, -- Open all filtered/selected files into buffers
      },
      n = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-o>"] = open_all,
      },
    },
  },
}

-- vim.keymap.set("n", "<Leader>sn", "<CMD>lua require('telescope').extensions.notify.notify()<CR>", silent)

