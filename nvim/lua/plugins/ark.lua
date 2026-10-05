-- ark.nvim: tmux agent pane. Default keymaps: <leader>ai edit selection (visual),
-- <leader>ao open agent pane, <leader>ah pick harness/model/effort.
require('ark').setup({
  harnesses = {
    claude = { cmd = { "claude", "--dangerously-skip-permissions" } },
    pi = { cmd = { "sh", "-c", 'OPENCODE_API_KEY=$(cat ~/.secrets/opencode) exec pi "$@"', "pi" } },
  },
})
