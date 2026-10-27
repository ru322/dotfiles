-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

vim.keymap.set("i", "jj", "<Esc>")

vim.keymap.set("n", "<M-Left>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<M-Down>", "<C-w>j", { desc = "Move to lower window" })
vim.keymap.set("n", "<M-Up>", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set("n", "<M-Right>", "<C-w>l", { desc = "Move to right window" })

vim.keymap.set("t", "<M-Left>", [[<C-\><C-n><C-w>h]], { desc = "Move to left window" })
vim.keymap.set("t", "<M-Down>", [[<C-\><C-n><C-w>j]], { desc = "Move to lower window" })
vim.keymap.set("t", "<M-Up>", [[<C-\><C-n><C-w>k]], { desc = "Move to upper window" })
vim.keymap.set("t", "<M-Right>", [[<C-\><C-n><C-w>l]], { desc = "Move to right window" })
