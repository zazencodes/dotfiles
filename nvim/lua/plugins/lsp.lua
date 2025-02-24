-- Diagnostic keymaps
vim.keymap.set('n', '<leader>dp', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<leader>dn', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>ds', vim.diagnostic.setloclist)

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gt', vim.lsp.buf.type_definition, 'Type [D]efinition')
  -- nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  -- nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  -- nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  -- nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  -- nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  -- nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  -- nmap('<leader>wl', function()
  --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  -- end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    if vim.lsp.buf.format then
      vim.lsp.buf.format()
    elseif vim.lsp.buf.formatting then
      vim.lsp.buf.formatting()
    end
  end, { desc = 'Format current buffer with LSP' })
end

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Enable the following language servers
-- Feel free to add/remove any LSPs that you want here. They will automatically be installed
local servers = {
  'pyright',
  'ruff',
  'tailwindcss',
  'volar',
  'ts_ls',
  'eslint'
}


local server_settings = {
  ruff_lsp = {},
  tsserver = {},
  pyright = {
    pyright = {
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        -- Ignore all files for analysis to exclusively use Ruff for linting
        ignore = { '*' },
        autoImportCompletions = false,
      },
    },
  },
}

-- Ensure the servers above are installed
require('mason-lspconfig').setup {
  ensure_installed = servers,
}

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

for _, lsp in ipairs(servers) do
  require('lspconfig')[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = server_settings[lsp],
  }
end

-- Turn on lsp status information
require('fidget').setup()

-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')



-- Python virtual env detection
-- local util = require("lspconfig/util")
-- local path = util.path
-- local function file_exists(name)
--   local f=io.open(name,"r")
--   if f~=nil then io.close(f) return true else return false end
-- end
-- local function get_python_path(workspace)
--   -- Use activated virtualenv.
--   if vim.env.VIRTUAL_ENV then
--     return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
--   end
--
--   -- Find and use virtualenv in workspace directory.
--   for _, pattern in ipairs({ "*", ".*" }) do
--     local match = vim.fn.glob(path.join(workspace, pattern, "pyvenv.cfg"))
--     if match ~= "" then
--       return path.join(path.dirname(match), "bin", "python")
--     end
--   end
--
--   default_venv_path = path.join(vim.env.HOME, "virtualenvs", "nvim-venv", "bin", "python")
--   if file_exists(default_venv_path) then
--     return default_venv_path
--   end
--
--   -- Default virtual environment
-- --   return path.join(vim.env.HOME, "virtualenvs", "nvim-venv", "bin", "python")
--
--   -- Fallback to system Python.
--   return exepath("python3") or exepath("python") or "python"
--
-- end
--
-- require('lspconfig').pyright.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   before_init = function(_, config)
--     config.settings.python.pythonPath = get_python_path(config.root_dir)
--   end,
-- }


-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup {
  view = {
  	entries = "native"
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = "neorg" },
  },
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = '*.sh',
  callback = function()
    vim.lsp.start({
      name = 'bash-language-server',
      cmd = { 'bash-language-server', 'start' },
    })
  end,
  -- { desc = 'Start bash language server' }
})


-- vim.api.nvim_create_autocmd('BufWritePre', {
--   pattern = '*.py',
--   callback = function()
--     if vim.lsp.buf.format then
--       vim.lsp.buf.format()
--     elseif vim.lsp.buf.formatting then
--       vim.lsp.buf.formatting()
--     end
--   end,
--   -- { desc = 'Format current buffer on save with LSP' }
-- })


-- vim.api.nvim_create_autocmd('BufWritePre', {
--   pattern = '*.js',
--   callback = function()
--     if vim.lsp.buf.format then
--       vim.lsp.buf.format()
--     elseif vim.lsp.buf.formatting then
--       vim.lsp.buf.formatting()
--     end
--   end,
--   -- { desc = 'Format current buffer on save with LSP' }
-- })

