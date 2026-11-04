-- Core Options & Colorscheme (Native Neovim)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- User Preferences
vim.g.autoformat = false
vim.opt.relativenumber = false
vim.opt.number = true
vim.opt.exrc = true
vim.opt.autoread = true

-- Disable unused runtime providers
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

-- Clipboard & Editing
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- UI & Windows
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 8

-- Behavior & Performance
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.undofile = true

-- Command Line & Wildmenu Completion
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"

-- Native LSP / Popup Completion
vim.opt.completeopt = { "menu", "menuone", "popup", "noselect" }
vim.opt.pumheight = 10 -- Limita a altura do popup para renderizacao rapida e sob demanda
vim.opt.pumwidth = 15

-- Use Ripgrep for :grep if installed
if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --smart-case --hidden --glob '!.git'"
  vim.opt.grepformat = "%f:%l:%c:%m"
end

-- Theme: Retrobox (Native Neovim Gruvbox) with transparency
vim.cmd.colorscheme("retrobox")
local transparent_groups = {
  "Normal",
  "NormalFloat",
  "NormalNC",
  "SignColumn",
  "FoldColumn",
  "Folded",
  "LineNr",
  "CursorLineNr",
  "EndOfBuffer",
}
for _, group in ipairs(transparent_groups) do
  vim.api.nvim_set_hl(0, group, { bg = "none", ctermbg = "none" })
end
