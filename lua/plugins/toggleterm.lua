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

            local function make_agent(cmd)
                return Terminal:new({
                    cmd = cmd,
                    dir = "git_dir",
                    direction = "float",
                    hidden = true,
                    close_on_exit = false,
                    float_opts = {
                        border = "double",
                    },
                    on_open = function(term)
                        vim.cmd("startinsert!")
                        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q",
                            "<cmd>close<CR>",
                            { noremap = true, silent = true })
                    end,
                    on_close = function(term)
                        vim.cmd("startinsert!")
                    end,
                })
            end

            local claude = make_agent("claude")
            local copilot = make_agent("copilot")

            function _lazygit_toggle()
                lazygit:toggle()
            end

            function _claude_toggle()
                claude:toggle()
            end

            function _copilot_toggle()
                copilot:toggle()
            end

            -- keymaps
            vim.api.nvim_set_keymap("n", "<leader>lz", "<cmd>lua _lazygit_toggle()<CR>", { noremap = true, silent = true })
            vim.api.nvim_set_keymap("n", "<leader>cl", "<cmd>lua _claude_toggle()<CR>", { noremap = true, silent = true })
            vim.api.nvim_set_keymap("n", "<leader>co", "<cmd>lua _copilot_toggle()<CR>", { noremap = true, silent = true })
            vim.keymap.set("n", "<C-`>", "<CMD>ToggleTerm<CR>")
            vim.keymap.set("t", "<C-`>", "<CMD>ToggleTerm<CR>")
            vim.keymap.set("v", "<space>s","<cmd>ToggleTermSendVisualSelection<cr>")

            -- Send to terminal without executing (no trailing newline)
            local function send_no_exec(text, id)
                local term = require("toggleterm.terminal").get_or_create_term(id or 1)
                if not term:is_open() then term:open() end
                vim.fn.chansend(term.job_id, text)
            end

            vim.api.nvim_create_user_command("TermStage", function(opts)
                local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
                send_no_exec(table.concat(lines, "\n"))
            end, { range = true })

            vim.keymap.set("n", "<space>S", "<cmd>TermStage<cr>")
            vim.keymap.set("v", "<space>S", ":TermStage<cr>")
        end,
    }
}

