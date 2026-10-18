-- Leader must be set before lazy.nvim loads plugins.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.o

-- Indentation (guess-indent overrides per file)
o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.breakindent = true

-- UI
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.cursorline = true
o.scrolloff = 10
o.showmode = false -- shown by lualine
o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
o.splitright = true
o.splitbelow = true

-- Search
o.ignorecase = true
o.smartcase = true
o.inccommand = "split"

-- Behaviour
o.mouse = "a"
o.undofile = true
o.confirm = true
o.updatetime = 250
o.timeoutlen = 300

-- Deferred: the clipboard provider can slow down startup.
vim.schedule(function()
  o.clipboard = "unnamedplus"
end)
