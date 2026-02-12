function ColorTheEditor(color)
    require("gruvbox").setup(
        {
            contrast = "soft" -- can be "soft", "hard" or ""
        }
    )
    color = color or "gruvbox"
    vim.cmd.colorscheme(color)
    vim.o.background = "dark"

    -- I dont remember what these do :(
	-- vim.api.nvim_set_hl(0, "Normal", {bg = "None"})
	-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "None" })
end

ColorTheEditor()
