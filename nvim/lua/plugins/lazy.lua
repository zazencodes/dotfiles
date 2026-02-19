-- Install lazylazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { "onsails/lspkind.nvim" },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup{
        on_attach = function(bufnr)
          local gitsigns = require('gitsigns')

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then
              vim.cmd.normal({']c', bang = true})
            else
              gitsigns.nav_hunk('next')
            end
          end)

          map('n', '[c', function()
            if vim.wo.diff then
              vim.cmd.normal({'[c', bang = true})
            else
              gitsigns.nav_hunk('prev')
            end
          end)

          -- Actions
          map('n', '<leader>hp', gitsigns.preview_hunk)
          map('n', '<leader>hi', gitsigns.preview_hunk_inline)

          -- Diff against uncommitted changes
          map('n', '<leader>hD', gitsigns.diffthis)

          -- Diff against HEAD~{count}; default count=1 if none given
          map('n', '<leader>hd', function()
            local n = vim.v.count1            -- 1 if you didn’t type a count
            require('gitsigns').diffthis('HEAD~' .. n)
          end, { desc = 'gitsigns: diff HEAD~{count}' })

          map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
          map('n', '<leader>hq', gitsigns.setqflist)

          -- Toggles
          map('n', '<leader>hw', gitsigns.toggle_word_diff)

          -- Blame (popup for current line)
          map('n', '<leader>hb', function()
            gitsigns.blame_line()
          end, { desc = 'gitsigns: blame line (full)' })

          -- Blame (whole buffer)
          map('n', '<leader>hB', '<Cmd>Gitsigns blame<CR>', { desc = 'gitsigns: blame buffer' })

        end
      }
    end
  },

  {
    "ziontee113/icon-picker.nvim",
    config = function()
      require("icon-picker").setup({ disable_legacy_commands = true })
    end
  },

  -- Required as of 2025-03. Check latest documentation
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = ":call mkdp#util#install()",
  },
  -- {
  --   "iamcco/markdown-preview.nvim",
  --   cmd = { "MarkdownPreviewToggle" },
  --   ft = { "markdown" },
  --   build = function() vim.fn["mkdp#util#install"]() end,
  -- },

  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    config = function()
      require('render-markdown').setup({
        -- Setting render modes like this causes less 'flicker' when changing
        -- between normal, visual and insert modes
        render_modes = { 'n', 'c', 't', 'v', 'V', '\22', 'i' },
        -- Disable signs in the left bar like headings and code snippets
        sign = { enabled = false },
        anti_conceal = {
          ignore = {
            code_background = true,
            head_background = true,
            indent = true,
            sign = true,
            virtual_lines = true,
          },
        },
        heading = {
          icons = {},
        },
        code = {
          border = 'thick',
          highlight_border = 'Normal',
        },
        checkbox = {
          unchecked = { icon = '󰄱' },
          checked   = { icon = '' },
        },
      })
    end,
  },

  { 'folke/zen-mode.nvim' },

  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    requires = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("nvim-tree").setup {
          sort = { sorter = "case_sensitive" },
          view = {
            width = 30,
            adaptive_size = true,
          },
          renderer = { group_empty = true },
          filters = { dotfiles = false },
        }
      end,
  },

  { "tpope/vim-surround" },

  { "ryanoasis/vim-devicons" },

  {
    "goolord/alpha-nvim",
    config = function ()
      local alpha = require'alpha'
      local dashboard = require'alpha.themes.dashboard'
      dashboard.section.header.val = {
        [[        ___                     ___          _____         ]],
        [[       /  /\      ___          /__/\        /  /::\        ]],
        [[      /  /:/_    /  /\         \  \:\      /  /:/\:\       ]],
        [[     /  /:/ /\  /  /:/          \  \:\    /  /:/  \:\      ]],
        [[    /  /:/ /:/ /__/::\      _____\__\:\  /__/:/ \__\:|     ]],
        [[   /__/:/ /:/  \__\/\:\__  /__/::::::::\ \  \:\ /  /:/     ]],
        [[   \  \:\/:/      \  \:\/\ \  \:\~~\~~\/  \  \:\  /:/      ]],
        [[    \  \::/        \__\::/  \  \:\  ~~~    \  \:\/:/       ]],
        [[     \  \:\        /__/:/    \  \:\         \  \::/        ]],
        [[      \  \:\       \__\/      \  \:\         \__\/         ]],
        [[       \__\/                   \__\/                       ]],
        [[        ___                       ___           ___        ]],
        [[       /  /\                     /  /\         /__/\       ]],
        [[      /  /:/_                   /  /::\       _\_ \:\      ]],
        [[     /  /:/ /\  ___     ___    /  /:/\:\     /__/\ \:\     ]],
        [[    /  /:/ /:/ /__/\   /  /\  /  /:/  \:\   _\_ \:\ \:\    ]],
        [[   /__/:/ /:/  \  \:\ /  /:/ /__/:/ \__\:\ /__/\ \:\ \:\   ]],
        [[   \  \:\/:/    \  \:\  /:/  \  \:\ /  /:/ \  \:\ \:\/:/   ]],
        [[    \  \::/      \  \:\/:/    \  \:\  /:/   \  \:\ \::/    ]],
        [[     \  \:\       \  \::/      \  \:\/:/     \  \:\/:/     ]],
        [[      \  \:\       \__\/        \  \::/       \  \::/      ]],
        [[       \__\/                     \__\/         \__\/       ]],
      }
      dashboard.section.buttons.val = {
        dashboard.button("e", "  New file", "<cmd>ene <CR>"),
        dashboard.button("SPC f o", "󰈞  Recently opened files"),
        dashboard.button( "q", "󰅚  Quit NVIM" , ":qa<CR>"),
      }
      local handle = io.popen('fortune')
      local fortune = handle:read("*a")
      handle:close()
      dashboard.section.footer.val = fortune

      dashboard.config.opts.noautocmd = true

      vim.cmd[[autocmd User AlphaReady echo 'ready']]

      alpha.setup(dashboard.config)
    end
  },

  {
    'rmagatti/auto-session',
    config = function()
      require("auto-session").setup {
        log_level = "error",
        auto_session_suppress_dirs = { "~/", "~/Downloads" },
      }
    end
  },


  {
    'rmagatti/goto-preview',
    config = function() require('goto-preview').setup {} end
  },

  { "catppuccin/nvim", as = "catppuccin" },

  {
    "windwp/nvim-autopairs",
      config = function() require("nvim-autopairs").setup {} end
  },

  {
    'terrortylor/nvim-comment',
    dependencies = 'JoosepAlviste/nvim-ts-context-commentstring',
    config = function()
      require("nvim_comment").setup({
        create_mappings = false,
        hook = function()
          if vim.api.nvim_buf_get_option(0, "filetype") == "vue" then
            vim.api.nvim_buf_set_option(0, "commentstring", "<!-- %s -->") -- hack for now
            -- require("ts_context_commentstring.internal").update_commentstring() -- this should work, but it doesnt. god damn
          end
        end
      })
    end
  },

  {'akinsho/bufferline.nvim', dependencies = 'nvim-tree/nvim-web-devicons'},

  -- { "chrisgrieser/nvim-spider" },

  {
    "folke/noice.nvim",
    config = function()
      require("noice").setup({
        -- add any options here
        routes = {
          {
            filter = {
              event = 'msg_show',
              any = {
                { find = '%d+L, %d+B' },
                { find = '; after #%d+' },
                { find = '; before #%d+' },
                { find = '%d fewer lines' },
                { find = '%d more lines' },
              },
            },
            opts = { skip = true },
          }
        },
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          lsp_doc_border = false, -- add a border to hover docs and signature help
        },
      })
    end,
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
    --   "rcarriga/nvim-notify",
    }
  },

  {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim", -- required by telescope
        "MunifTanjim/nui.nvim",

        -- optional
        "nvim-treesitter/nvim-treesitter",
        -- "rcarriga/nvim-notify",
        -- "nvim-tree/nvim-web-devicons",
    },
    opts = {
      lang = "python",
    },
  },

  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      'j-hui/fidget.nvim',
    }
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    }
  },

   -- Fancier statusline
  { 'nvim-lualine/lualine.nvim' },

  -- Fuzzy Finder (files, lsp, etc)
  { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },
  { 'nvim-telescope/telescope-symbols.nvim' },

  { "folke/twilight.nvim", opts = { } },

  -- Treesitter playground
  { "nvim-treesitter/nvim-treesitter" },
  { "nvim-treesitter/playground" },

  -- {
  --   'kristijanhusak/vim-dadbod-ui',
  --   dependencies = {
  --     { 'tpope/vim-dadbod', lazy = true },
  --     { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true }, -- Optional
  --   },
  --   cmd = {
  --     'DBUI',
  --     'DBUIToggle',
  --     'DBUIAddConnection',
  --     'DBUIFindBuffer',
  --   },
  --   init = function()
  --     -- Your DBUI configuration
  --     vim.g.db_ui_use_nerd_fonts = 1
  --     vim.g.db_ui_execute_on_save = 0
  --   end,
  -- },

  -- {
  --   "olimorris/codecompanion.nvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  --   config = function()
  --     require("codecompanion").setup({
  --       strategies = {
  --         chat = {
  --           adapter = "anthropic",
  --         },
  --         inline = {
  --           adapter = "anthropic",
  --         },
  --       },
  --       extensions = {
  --         mcphub = {
  --           callback = "mcphub.extensions.codecompanion",
  --           opts = {
  --             show_result_in_chat = true,  -- Show mcp tool results in chat
  --             make_vars = true,            -- Convert resources to #variables
  --             make_slash_commands = true,  -- Add prompts as /slash commands
  --           }
  --         }
  --       }
  --     })
  --   end
  -- },

  {
      "ravitemer/mcphub.nvim",
      dependencies = {
          "nvim-lua/plenary.nvim",
      },
      build = "npm install -g mcp-hub@latest",  -- Installs `mcp-hub` node binary globally
      config = function()
          require("mcphub").setup()
      end
  },

  -- {
  --   "yetone/avante.nvim",
  --   event = "VeryLazy",
  --   lazy = false,
  --   version = false, -- set this if you want to always pull the latest change
  --   opts = {
  --     provider = "claude",
  --     claude = {
  --       disable_tools = true, -- disable tools!
  --       model = "claude-3.5-haiku-latest"
  --       -- model = "claude-3-7-sonnet-latest",
  --     },
  --   },
  --   -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  --   build = "make",
  --   -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  --   dependencies = {
  --     "nvim-treesitter/nvim-treesitter",
  --     "stevearc/dressing.nvim",
  --     "nvim-lua/plenary.nvim",
  --     "MunifTanjim/nui.nvim",
  --     --- The below dependencies are optional,
  --     "echasnovski/mini.pick", -- for file_selector provider mini.pick
  --     "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
  --     "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
  --     "ibhagwan/fzf-lua", -- for file_selector provider fzf
  --     "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
  --     -- "zbirenbaum/copilot.lua", -- for providers='copilot'
  --     {
  --       -- support for image pasting
  --       "HakonHarnes/img-clip.nvim",
  --       event = "VeryLazy",
  --       opts = {
  --         -- recommended settings
  --         default = {
  --           embed_image_as_base64 = false,
  --           prompt_for_file_name = false,
  --           drag_and_drop = {
  --             insert_mode = true,
  --           },
  --           -- required for Windows users
  --           use_absolute_path = true,
  --         },
  --       },
  --     },
  --     {
  --       -- Make sure to set this up properly if you have lazy=true
  --       'MeanderingProgrammer/render-markdown.nvim',
  --       opts = {
  --         file_types = { "markdown", "Avante" },
  --       },
  --       ft = { "markdown", "Avante" },
  --     },
  --   },
  --   config = function()
  --     require("avante").setup({
  --       -- system_prompt as function ensures LLM always has latest MCP server state
  --       -- This is evaluated for every message, even in existing chats
  --       system_prompt = function()
  --           local hub = require("mcphub").get_hub_instance()
  --           return hub and hub:get_active_servers_prompt() or ""
  --       end,
  --       -- Using function prevents requiring mcphub before it's loaded
  --       custom_tools = function()
  --           return {
  --               require("mcphub.extensions.avante").mcp_tool(),
  --           }
  --       end,
  --     })
  --   end
  -- },

  {
    "nomnivore/ollama.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    -- All the user commands added by the plugin
    cmd = { "Ollama", "OllamaModel", "OllamaServe", "OllamaServeStop" },

    keys = {
      -- Sample keybind for prompt menu. Note that the <c-u> is important for selections to work properly.
      {
        "<leader>oo",
        ":<c-u>lua require('ollama').prompt()<cr>",
        desc = "ollama prompt",
        mode = { "n", "v" },
      },

      -- Sample keybind for direct prompting. Note that the <c-u> is important for selections to work properly.
      {
        "<leader>oG",
        ":<c-u>lua require('ollama').prompt('Generate_Code')<cr>",
        desc = "ollama Generate Code",
        mode = { "n", "v" },
      },
    },

    ---@type Ollama.Config
    opts = {
      model = "gemma3:4b",
      url = "http://127.0.0.1:11434",
      -- View the actual default prompts in ./lua/ollama/prompts.lua
      prompts = {
        Sample_Prompt = {
          prompt = "This is a sample prompt that receives $input and $sel(ection), among others.",
          input_label = "> ",
          model = "mistral",
          action = "display",
        }
      }
    }
  },

  {
    "allaman/emoji.nvim",
    version = "1.0.0", -- optionally pin to a tag
    ft = "markdown", -- adjust to your needs
    dependencies = {
      -- util for handling paths
      "nvim-lua/plenary.nvim",
      -- optional for nvim-cmp integration
      "hrsh7th/nvim-cmp",
      -- optional for telescope integration
      "nvim-telescope/telescope.nvim",
      -- optional for fzf-lua integration via vim.ui.select
      "ibhagwan/fzf-lua",
    },
    opts = {
      -- default is false, also needed for blink.cmp integration!
      -- enable_cmp_integration = true,
      -- optional if your plugin installation directory
      -- is not vim.fn.stdpath("data") .. "/lazy/
      -- plugin_path = vim.fn.expand("$HOME/plugins/"),
    },
    config = function(_, opts)
      require("emoji").setup(opts)
      -- optional for telescope integration
      local ts = require('telescope').load_extension 'emoji'
      vim.keymap.set('n', '<leader>se', ts.emoji, { desc = '[S]earch [E]moji' })
    end,
  },

})

