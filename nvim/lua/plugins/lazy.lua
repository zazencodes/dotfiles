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
      require('gitsigns').setup()
    end
  },

  {
    "ziontee113/icon-picker.nvim",
    config = function()
      require("icon-picker").setup({ disable_legacy_commands = true })
    end
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
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

  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod', lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true }, -- Optional
    },
    cmd = {
      'DBUI',
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUIFindBuffer',
    },
    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_execute_on_save = 0
    end,
  },

  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      -- provider = "ollama",
      -- vendors = {
      --   ollama = {
      --     __inherited_from = "openai",
      --     api_key_name = "",
      --     endpoint = "http://127.0.0.1:11434/v1",
      --     model = "deepseek-r1:8b",
      --   },
      -- },
      --
      provider = "claude",
      claude = {
        model = "claude-3-7-sonnet-latest",
      },

      -- provider = "openai",
      -- openai = {
      --   model = "gpt-4o-mini",
      -- },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
    init = function()
      -- Recommended option
      -- views can only be fully collapsed with the global statusline
      vim.opt.laststatus = 3
    end,
  }


})

