function ColorTheEditor(color)
	color = color or "gruvbox"
	vim.cmd.colorscheme(color)
	vim.o.background = "dark"

	vim.api.nvim_set_hl(0, "Normal", { bg = "None" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "None" })
end

ColorTheEditor()
