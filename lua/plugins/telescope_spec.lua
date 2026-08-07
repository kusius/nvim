return {
    {
        "nvim-telescope/telescope.nvim", version = "*",
        lazy = false,
        dependencies ={
            { "nvim-lua/plenary.nvim" },
            -- C fuzzy sorter; the Lua default re-scores every candidate on each
            -- keystroke, which is the real bottleneck on big repos (yogurt: ~44k files)
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            require("telescope").setup({
                pickers = {
                    find_files = {
                        find_command = {
                            "rg", "--files",
                            "--hidden",          -- .rubocop.yml, .herb.yml, .github/copilot/**
                            "--glob=!.git/**",
                            -- ~5k committed images/fonts/binaries (mostly app/assets/images)
                            "--glob=!**/*.{png,jpg,jpeg,gif,svg,webp,ico,woff,woff2,eot,ttf,xlsx,eml,pdf}",
                        },
                    },
                },
            })
            require("telescope").load_extension("fzf")

            local builtin = require('telescope.builtin')
            vim.keymap.set('n', "<C-f>", builtin.find_files, {})
            vim.keymap.set('n', "<leader>fg", builtin.git_files, {})
            vim.keymap.set('n', '<leader>ff', builtin.live_grep, { desc = 'Telescope live grep' })
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
                        "--glob=tests/**",        -- everything in tests/ directory
                        "--glob=spec/**",        -- everything in spec/ directory
                    }
                })
            end, { desc = "Go to test for symbol under cursor" })

        end,
    },
}
