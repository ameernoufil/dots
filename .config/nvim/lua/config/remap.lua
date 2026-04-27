-- Leader
vim.g.mapleader = " "

-- Lazy Vim
vim.g.maplocalleader = "\\"

-- Netrw
vim.keymap.set("n", "<leader>pe", vim.cmd.Ex)

-- Lazy
vim.keymap.set("n", "<leader>lv", vim.cmd.Lazy)

-- System Yank
vim.keymap.set({ "n", "x" }, "<leader>y", '"+y')

