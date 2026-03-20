-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
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

-- Set lightline config BEFORE lazy.setup so it's available when lightline loads
vim.cmd([[
function! LightlineFilename() abort
  return empty(expand('%:p')) ? '[No Name]' : expand('%:p')
endfunction
]])

vim.g.lightline = {
  colorscheme = "onedark",
  active = {
    left = {
      { "mode", "paste" },
      { "gitbranch", "readonly", "filename", "modified" },
    },
  },
  component_function = {
    gitbranch = "FugitiveHead",
    filename = "LightlineFilename",
  },
}

require("lazy").setup({
  -- Git commands in nvim
  "tpope/vim-fugitive",
  -- Fugitive-companion to interact with github
  "tpope/vim-rhubarb",
  -- "gc" to comment visual regions/lines
  "tpope/vim-commentary",
  -- UI to select things (files, grep results, open buffers...)
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  -- Theme inspired by Atom
  "joshdick/onedark.vim",
  -- Fancier statusline
  "itchyny/lightline.vim",
  -- Add indentation guides even on blank lines
  "lukas-reineke/indent-blankline.nvim",
  -- Add git related info in the signs columns and popups
  { "lewis6991/gitsigns.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  -- Collection of configurations for built-in LSP client
  "neovim/nvim-lspconfig",
  -- Autocompletion plugin
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  "hrsh7th/cmp-vsnip",
  "hrsh7th/vim-vsnip",
  "hashivim/vim-terraform",
})

vim.opt.completeopt = { "menu", "menuone", "noselect" }

vim.o.shell = "/bin/zsh"
--Incremental live completion
vim.o.inccommand = "nosplit"

--Set highlight on search
vim.o.hlsearch = true
vim.o.incsearch = true

--Make line numbers default
vim.wo.number = true

--Do not save when switching buffers
vim.o.hidden = true

--Enable mouse mode
vim.o.mouse = "a"

--Auto-reload files changed outside nvim
vim.o.autoread = true

--Enable break indent
vim.o.breakindent = true

--Save undo history
vim.cmd([[set undofile]])

vim.o.sw = 4
vim.o.ts = 4
vim.o.et = true

--Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

--Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = "yes"

--Set colorscheme (order is important here)
vim.o.termguicolors = true
vim.g.onedark_terminal_italics = 2
vim.cmd([[colorscheme onedark]])

--Remap space as leader key
vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })

--Remap escape to leave terminal mode
vim.keymap.set("t", "<Esc>", [[<c-\><c-n>]])

vim.api.nvim_create_user_command("E", "Explore", {})

-- Map blankline (updated for indent-blankline v3)
local highlight = {
  "CursorColumn",
  "Whitespace",
  "LineNr",
}
require("ibl").setup({
  indent = {
    highlight = highlight,
    char = "┊",
  },
  exclude = {
    filetypes = { "help", "lazy" },
    buftypes = { "terminal", "nofile" },
  },
  scope = { enabled = false },
})
ToggleMouse = function()
  if vim.o.mouse == "a" then
    vim.cmd([[IBLDisable]])
    vim.wo.signcolumn = "no"
    vim.o.mouse = "v"
    vim.wo.number = false
    print("Mouse disabled")
  else
    vim.cmd([[IBLEnable]])
    vim.wo.signcolumn = "yes"
    vim.o.mouse = "a"
    vim.wo.number = true
    print("Mouse enabled")
  end
end
vim.keymap.set("n", "<F10>", ToggleMouse)

vim.keymap.set("n", "<leader>T", ":tabnew<CR>")

-- Telescope
require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<C-u>"] = false,
        ["<C-d>"] = false,
      },
    },
    generic_sorter = require("telescope.sorters").get_fzy_sorter,
    file_sorter = require("telescope.sorters").get_fzy_sorter,
  },
  pickers = {
    buffers = {
      mappings = {
        i = {
          ["<C-d>"] = require("telescope.actions").delete_buffer + require("telescope.actions").move_to_top,
        },
      },
    },
  },
})

--Add leader shortcuts
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>f", builtin.find_files)
vim.keymap.set("n", "<leader><space>", builtin.buffers)
vim.keymap.set("n", "<leader>l", builtin.current_buffer_fuzzy_find)
vim.keymap.set("n", "<leader>t", builtin.tags)
vim.keymap.set("n", "<leader>?", builtin.oldfiles)
vim.keymap.set("n", "<leader>sd", builtin.grep_string)
vim.keymap.set("n", "<leader>sp", builtin.live_grep)
vim.keymap.set("n", "<leader>o", function() builtin.tags({ only_current_buffer = true }) end)
vim.keymap.set("n", "<leader>gc", builtin.git_commits)
vim.keymap.set("n", "<leader>gb", builtin.git_branches)
vim.keymap.set("n", "<leader>gs", builtin.git_status)
vim.keymap.set("n", "<leader>gp", builtin.git_bcommits)

-- Change preview window location
vim.g.splitbelow = true

--
-- LSP settings
local on_attach = function(_client, bufnr)
  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

  local map = function(keys, func) vim.keymap.set("n", keys, func, { buffer = bufnr }) end
  map("gD", vim.lsp.buf.declaration)
  map("gd", vim.lsp.buf.definition)
  map("K", vim.lsp.buf.hover)
  map("gi", vim.lsp.buf.implementation)
  map("<C-k>", vim.lsp.buf.signature_help)
  map("<leader>wa", vim.lsp.buf.add_workspace_folder)
  map("<leader>wr", vim.lsp.buf.remove_workspace_folder)
  map("<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end)
  map("<leader>D", vim.lsp.buf.type_definition)
  map("<leader>rn", vim.lsp.buf.rename)
  map("gr", vim.lsp.buf.references)
  map("<leader>ca", vim.lsp.buf.code_action)
  map("<leader>e", vim.diagnostic.open_float)
  map("[d", vim.diagnostic.goto_prev)
  map("]d", vim.diagnostic.goto_next)
  map("<leader>q", vim.diagnostic.setloclist)
end

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
    end,
  },
  mapping = {
    ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif vim.fn["vsnip#available"](1) == 1 then
        feedkey("<Plug>(vsnip-expand-or-jump)", "")
      elseif has_words_before() then
        cmp.complete()
      else
        fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item()
      elseif vim.fn["vsnip#jumpable"](-1) == 1 then
        feedkey("<Plug>(vsnip-jump-prev)", "")
      end
    end, { "i", "s" }),
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "vsnip" }, -- For vsnip users.
  }, {
    { name = "buffer" },
  }),
})

--nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.positionEncoding = "utf-16"
capabilities.workspace = capabilities.workspace or {}
capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = true }
-- setup languages
-- GoLang
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.lsp.start({
      name = "gopls",
      cmd = { "gopls" },
      -- Find nearest go.mod; for external files (module cache, Go stdlib)
      -- reuse existing gopls to avoid spawning a separate instance
      root_dir = (function()
        local bufpath = vim.api.nvim_buf_get_name(0)
        local goroot = os.getenv("GOROOT") or vim.fn.system("go env GOROOT"):gsub("%s+$", "")
        local gopath = os.getenv("GOPATH") or (vim.env.HOME .. "/go")
        -- External file: inside GOROOT or module cache
        if bufpath:find(goroot, 1, true) or bufpath:find(gopath .. "/pkg/mod/", 1, true) then
          for _, client in ipairs(vim.lsp.get_clients({ name = "gopls" })) do
            return client.config.root_dir
          end
        end
        local modfile = vim.fs.find({ "go.mod" }, { upward = true, path = bufpath })[1]
        return modfile and vim.fs.dirname(modfile) or nil
      end)(),
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        gopls = {
          buildFlags = { "-tags=integration" },
          experimentalPostfixCompletions = true,
          analyses = {
            unusedparams = true,
            shadow = true,
          },
          staticcheck = true,
        },
      },
      init_options = {
        usePlaceholders = true,
      },
    })
  end,
})

vim.keymap.set("n", "<C-n>", ":cn<CR>")
vim.keymap.set("n", "<C-p>", ":cp<CR>")
vim.keymap.set("n", "<C-c>", ":ccl<CR>")

function goimports(timeoutms)
  local params = vim.lsp.util.make_range_params(nil, vim.lsp.util._get_offset_encoding())
  params.context = { only = { "source.organizeImports" } }
  -- buf_request_sync defaults to a 1000ms timeout. Depending on your
  -- machine and codebase, you may want longer. Add an additional
  -- argument after params if you find that you have to write the file
  -- twice for changes to be saved.
  -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeoutms)
  for cid, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
        vim.lsp.util.apply_workspace_edit(r.edit, enc)
      end
    end
  end
  vim.lsp.buf.format({ async = false })
end

local augroup = vim.api.nvim_create_augroup("auto_cmds", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Re-check files changed on disk (e.g. after git checkout, external edits)
-- when switching back to nvim or entering a buffer
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = augroup,
  command = "checktime",
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  pattern = "*.go",
  callback = function()
    goimports(3000)
  end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = augroup,
  pattern = "*.tf",
  command = "set syntax=tf",
})
