return {
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        config = function()
            require("toggleterm").setup({})


            -- set lazygit to open via shortcut in float window
            -- and close via shortcut key as well ('q')
            local Terminal = require('toggleterm.terminal').Terminal
            local lazygit = Terminal:new({
                cmd = "lazygit",
                dir = "git_dir",
                direction = "float",
                float_opts = {
                    border = "double",
                },
                on_open = function(term)
                    vim.cmd("startinsert!")
                    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
                end,
                on_close = function(term)
                    vim.cmd("startinsert!")
                end,
            })

            function _lazygit_toggle()
                lazygit:toggle()
            end

            -- keymaps
            vim.api.nvim_set_keymap("n", "<leader>lz", "<cmd>lua _lazygit_toggle()<CR>", { noremap = true, silent = true })
            vim.keymap.set("n", "<C-`>", "<CMD>ToggleTerm<CR>")
            vim.keymap.set("t", "<C-`>", "<CMD>ToggleTerm<CR>")

            local trim_spaces = true
            vim.keymap.set("v", "<space>s", function()
                require("toggleterm").send_lines_to_terminal("visual_selection", trim_spaces, { args = vim.v.count })
            end)
        end,
    }
}

