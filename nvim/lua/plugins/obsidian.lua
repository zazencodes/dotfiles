require("obsidian").setup({
  legacy_commands = false,
  workspaces = {
    {
      name = "AzathHouse",
      path = "/Users/alex/obsidian/AzathHouse",
    },
  },
  notes_subdir = "inbox",
  new_notes_location = "notes_subdir",

  frontmatter = { enabled = false },
  templates = {
    folder = "Agents/Templates",
    date_format = "YYYY-MM-DD",
    time_format = "HH:mm:ss",
  },

  -- gf follows wiki/markdown links via the plugin's includeexpr
  callbacks = {
    enter_note = function()
      -- toggle check-boxes
      vim.keymap.set("n", "<leader>ti", "<cmd>Obsidian toggle_checkbox<cr>", { buffer = true })
    end,
  },
  ui = { enable = false }, -- render-markdown.nvim handles all markdown UI
})
