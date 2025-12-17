-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Open diagnostics with CTRL + ,
vim.keymap.set("n", "<C-,>", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })

-- Reload Lazyvim Config
vim.keymap.set("n", "<leader>rr", "<cmd>source $MYVIMRC<cr>", { desc = "Reload config" })
