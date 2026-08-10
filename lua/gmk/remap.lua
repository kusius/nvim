vim.keymap.set("n", "<leader>pv", "<CMD>Oil<CR>")
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" } )
vim.keymap.set("n", "gb", "<C-o>", { desc = "Go back to previous position" })
vim.keymap.set("n", "gf", "<C-i>", { desc = "Go forward in jump list" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
vim.keymap.set("n", "<leader>a", ':<c-u>ArgonautToggle<cr>', {noremap = true, silent = true})
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.setqflist, { desc = "Show all diagnostics" })

-- lua (yog specific)
vim.keymap.set("n", "<leader>ta", "<CMD>A<CR>",  { desc = "Rails: alternate (impl <-> spec)" })
vim.keymap.set("n", "<leader>tv", "<CMD>AV<CR>", { desc = "Rails: alternate in vsplit" })

-- toggleterm
vim.keymap.set("t", "<C-q>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

vim.api.nvim_create_user_command("Makes", function(opts)
vim.cmd("silent make " .. opts.args .. " | redraw!")
if not vim.tbl_isempty(vim.fn.getqflist()) then
  vim.cmd("copen") -- open and focus the quickfix window
end
end, { nargs = "*", desc = "Compile silently and focus quickfix" })
