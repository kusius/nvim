local builtin = require('telescope.builtin')
vim.keymap.set('n', "<C-f>", builtin.find_files, {})
vim.keymap.set('n', "<leader>ff", builtin.git_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<C-s>', builtin.lsp_document_symbols, { desc = 'List document symbols' })
vim.keymap.set('n', '<leader>fs', function() 
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
vim.keymap.set("n", "gt", function()
	local symbol = vim.fn.expand("<cword>")
	builtin.grep_string({
		search = symbol,
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--glob=*[tT]est*",
			"--glob=test/**",         -- everything in test/ directory
			"--glob=tests/**",        -- everything in tests/ director
		}
	})
end, { desc = "Go to test for symbol under cursor" })

