vim.g.mapleader = ","
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" } )
vim.keymap.set("n", "gb", "<C-o>", { desc = "Go back to previous position" })
vim.keymap.set("n", "gf", "<C-i>", { desc = "Go forward in jump list" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
vim.keymap.set("n", "<leader>a", ':<c-u>ArgonautToggle<cr>', {noremap = true, silent = true})
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

