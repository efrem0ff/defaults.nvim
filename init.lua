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
  -- Collection of configurations for built-in LSP client
  "neovim/nvim-lspconfig",
  -- Autocompletion plugin
  {
    "saghen/blink.cmp",
    -- Tagged release, so lazy.nvim fetches the prebuilt matcher binary instead
    -- of needing a Rust toolchain.
    version = "1.*",
    opts = {
      keymap = {
        preset = "none",
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "show", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        -- Snippet placeholders get their own keys. <Tab> cannot serve both,
        -- because inside a snippet the completion menu reopens as soon as you
        -- type.
        ["<C-l>"] = { "snippet_forward", "fallback" },
        ["<C-h>"] = { "snippet_backward", "fallback" },
      },
      completion = {
        -- Nothing is selected until you ask, so <CR> still inserts a newline.
        list = { selection = { preselect = false } },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          buffer = { min_keyword_length = 3, score_offset = -3 },
          path = { score_offset = -1 },
        },
      },
      fuzzy = {
        implementation = "prefer_rust_with_warning",
        -- sort_text carries the ranking gopls computed. Keeping it in the chain
        -- is the whole point of the switch away from nvim-cmp.
        sorts = { "exact", "score", "sort_text" },
      },
      signature = { enabled = true },
    },
  },
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
vim.keymap.set("", "<Space>", "<Nop>", { desc = "Disable space so it can act as leader" })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Up by screen line when no count" })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Down by screen line when no count" })

--Remap escape to leave terminal mode
vim.keymap.set("t", "<Esc>", [[<c-\><c-n>]], { desc = "Leave terminal mode" })

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
local ToggleMouse = function()
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
vim.keymap.set("n", "<F10>", ToggleMouse, { desc = "Toggle mouse, signs, numbers and indent guides" })

vim.keymap.set("n", "<leader>T", ":tabnew<CR>", { desc = "New tab" })

-- Telescope
require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
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
vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader><space>", builtin.buffers, { desc = "Find open buffers" })
vim.keymap.set("n", "<leader>l", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find in current buffer" })
vim.keymap.set("n", "<leader>?", builtin.oldfiles, { desc = "Find recently opened files" })
vim.keymap.set("n", "<leader>sd", builtin.grep_string, { desc = "Grep word under cursor" })
vim.keymap.set("n", "<leader>sp", builtin.live_grep, { desc = "Grep in project" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "Reopen last picker" })
-- Grep inside a directory, prompted. In-editor `cd <dir> && rg <name>`.
vim.keymap.set("n", "<leader>sf", function()
  local buf = vim.api.nvim_buf_get_name(0)
  local default = buf ~= "" and vim.fn.fnamemodify(buf, ":h:.") .. "/" or "."
  vim.ui.input({ prompt = "Dir: ", default = default, completion = "dir" }, function(input)
    if not input or input == "" then
      return
    end
    local dir = vim.fn.fnamemodify(vim.fn.expand(input), ":p")
    if vim.fn.isdirectory(dir) == 0 then
      vim.notify("Not a directory: " .. input, vim.log.levels.ERROR)
      return
    end
    builtin.live_grep({
      cwd = dir,
      prompt_title = "Grep in " .. vim.fn.fnamemodify(dir, ":~:."),
    })
  end)
end, { desc = "Grep in a prompted directory" })
vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git status" })
vim.keymap.set("n", "<leader>gp", builtin.git_bcommits, { desc = "Git commits for current buffer" })

-- Change preview window location
vim.o.splitbelow = true

--
-- LSP settings

-- nvim 0.11 ships global grr/grn/gra/gri/grt, which makes plain gr wait
-- timeoutlen before firing. The maps below cover all five.
for _, key in ipairs({ "grr", "grn", "gra", "gri", "grt" }) do
  pcall(vim.keymap.del, "n", key)
end

local on_attach = function(_client, bufnr)
  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

  local map = function(keys, func, desc)
    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
  end
  map("gD", vim.lsp.buf.declaration, "Go to declaration")
  map("gd", vim.lsp.buf.definition, "Go to definition")
  map("gi", vim.lsp.buf.implementation, "Go to implementation")
  map("<C-k>", vim.lsp.buf.signature_help, "Signature help")
  map("<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
  map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
  map("<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "List workspace folders")
  map("<leader>D", vim.lsp.buf.type_definition, "Go to type definition")
  map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
  map("gr", vim.lsp.buf.references, "List references")
  map("<leader>ca", vim.lsp.buf.code_action, "Code action")
  map("<leader>e", vim.diagnostic.open_float, "Show diagnostic in a float")
  map("[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
  end, "Previous diagnostic")
  map("]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
  end, "Next diagnostic")
  map("<leader>q", vim.diagnostic.setloclist, "Diagnostics to location list")
end

-- setup languages
-- GoLang
-- Merges into the gopls config nvim-lspconfig ships, which already reuses a
-- running gopls for module cache and stdlib files.
vim.lsp.config("gopls", {
  on_attach = on_attach,
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
vim.lsp.enable("gopls")

-- Terraform
-- The default markers are .terraform and .git, so a module directory without
-- .terraform roots the server at the repository top instead. Terraform works a
-- directory at a time, so that directory is the right fallback.
vim.lsp.config("terraformls", {
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    -- Passing our own on_attach replaces the one nvim-lspconfig sets, which
    -- is the only thing turning code lens on.
    vim.lsp.codelens.enable(true, { bufnr = bufnr })
  end,
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    on_dir(vim.fs.root(fname, { ".terraform", ".terraform.lock.hcl" }) or vim.fs.dirname(fname))
  end,
})
vim.lsp.enable("terraformls")

vim.keymap.set("n", "<C-n>", ":cn<CR>", { desc = "Next quickfix entry" })
vim.keymap.set("n", "<C-p>", ":cp<CR>", { desc = "Previous quickfix entry" })
vim.keymap.set("n", "<C-c>", ":ccl<CR>", { desc = "Close quickfix window" })

-- Runs synchronously because BufWritePre writes the buffer the moment its
-- callback returns, which rules out the async vim.lsp.buf.code_action.
local function organize_imports(client, timeout_ms)
  local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
  params.context = { only = { "source.organizeImports" } }

  local res = client:request_sync("textDocument/codeAction", params, timeout_ms, 0)
  for _, action in pairs(res and res.result or {}) do
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    end
  end
end

local augroup = vim.api.nvim_create_augroup("auto_cmds", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.hl.on_yank()
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
    local client = vim.lsp.get_clients({ bufnr = 0, name = "gopls" })[1]
    if not client then
      return
    end
    organize_imports(client, 3000)
    vim.lsp.buf.format({ async = false })
  end,
})

-- Render markdown with glow. Terminal buffer because glow only colors to a tty.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<leader>md", function()
      vim.cmd("write")
      local file = vim.api.nvim_buf_get_name(0)
      vim.cmd("enew")
      vim.fn.jobstart({ "glow", file }, { term = true })
      vim.cmd("stopinsert")
      vim.keymap.set("n", "q", "<cmd>bdelete!<cr>", { buffer = true, desc = "Close glow preview" })
    end, { buffer = true, desc = "Render markdown with glow" })
  end,
})
