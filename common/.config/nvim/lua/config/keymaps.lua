vim.keymap.set("n", "<S-Tab>", "<<")
vim.keymap.set("n", "<Tab>", ">>")
vim.keymap.set("i", "<S-Tab>", "<C-d>")
vim.keymap.set("i", "jj", "<Esc>")

vim.keymap.set("n", "<M-Left>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<M-Down>", "<C-w>j", { desc = "Move to lower window" })
vim.keymap.set("n", "<M-Up>", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set("n", "<M-Right>", "<C-w>l", { desc = "Move to right window" })

vim.keymap.set("i", "<M-Left>", "<C-o><C-w>h", { desc = "Move to left window" })
vim.keymap.set("i", "<M-Down>", "<C-o><C-w>j", { desc = "Move to lower window" })
vim.keymap.set("i", "<M-Up>", "<C-o><C-w>k", { desc = "Move to upper window" })
vim.keymap.set("i", "<M-Right>", "<C-o><C-w>l", { desc = "Move to right window" })

vim.keymap.set("t", "<M-Left>", [[<C-\><C-n><C-w>h]], { desc = "Move to left window" })
vim.keymap.set("t", "<M-Down>", [[<C-\><C-n><C-w>j]], { desc = "Move to lower window" })
vim.keymap.set("t", "<M-Up>", [[<C-\><C-n><C-w>k]], { desc = "Move to upper window" })
vim.keymap.set("t", "<M-Right>", [[<C-\><C-n><C-w>l]], { desc = "Move to right window" })
