return {
    {
        "ellisonleao/gruvbox.nvim" ,
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            -- load the colorscheme here
            require("gruvbox").setup(
                {
                    contrast = "soft" -- can be "soft", "hard" or ""
                }
            )
            vim.cmd([[colorscheme gruvbox]])
            vim.o.background = "dark"
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ':TSUpdate',
        config = function()
            require("nvim-treesitter").install {
                "kotlin",
                "c",
                "lua",
                "go",
                "c3",
                "json"
            }
        end,
    },

    {
        "https://git.sr.ht/~foosoft/argonaut.nvim"
    },

    {
        "numToStr/Comment.nvim",
        opts = {
            mappings = false,
        },
        config = function(_, opts)
            require("Comment").setup(opts)
            -- Re-add only the line-comment mappings; skip the gb* block ones
            -- because they clash with our gb mapping (go back) in remap.lua.
            vim.keymap.set("n", "gcc",
            "<Plug>(comment_toggle_linewise_current)",
            { desc = "Comment current line" })
            vim.keymap.set("n", "gc",
            "<Plug>(comment_toggle_linewise)",
            { desc = "Comment linewise" })
            vim.keymap.set("x", "gc",
            "<Plug>(comment_toggle_linewise_visual)",
            { desc = "Comment linewise (visual)" })
        end,
    },

    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = { c = { "clang-format" }, cpp = { "clang-format" } },
            formatters = {
                ["clang-format"] = {
                    command = "clang-format",
                },
            },
        },
        init = function()
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
    },

    {
        -- manages external nvim tools such as dap, lsp servers
        -- linters, formatters
        "mason-org/mason.nvim",
        opts = {}
    },
    {
        "brenton-leighton/multiple-cursors.nvim",
        version = "*",  -- Use the latest tagged version
        opts = {},  -- This causes the plugin setup function to be called
        keys = {
            {"<C-j>", "<Cmd>MultipleCursorsAddDown<CR>", mode = {"n", "x"}, desc = "Add cursor and move down"},
            {"<C-k>", "<Cmd>MultipleCursorsAddUp<CR>", mode = {"n", "x"}, desc = "Add cursor and move up"},

            {"<C-Up>", "<Cmd>MultipleCursorsAddUp<CR>", mode = {"n", "i", "x"}, desc = "Add cursor and move up"},
            {"<C-Down>", "<Cmd>MultipleCursorsAddDown<CR>", mode = {"n", "i", "x"}, desc = "Add cursor and move down"},

            {"<C-LeftMouse>", "<Cmd>MultipleCursorsMouseAddDelete<CR>", mode = {"n", "i"}, desc = "Add or remove cursor"},

            {"<Leader>m", "<Cmd>MultipleCursorsAddVisualArea<CR>", mode = {"x"}, desc = "Add cursors to the lines of the visual area"},

            {"<Leader>a", "<Cmd>MultipleCursorsAddMatches<CR>", mode = {"n", "x"}, desc = "Add cursors to cword"},
            {"<Leader>A", "<Cmd>MultipleCursorsAddMatchesV<CR>", mode = {"n", "x"}, desc = "Add cursors to cword in previous area"},

            {"<Leader>d", "<Cmd>MultipleCursorsAddJumpNextMatch<CR>", mode = {"n", "x"}, desc = "Add cursor and jump to next cword"},
            {"<Leader>D", "<Cmd>MultipleCursorsJumpNextMatch<CR>", mode = {"n", "x"}, desc = "Jump to next cword"},

            {"<Leader>l", "<Cmd>MultipleCursorsLock<CR>", mode = {"n", "x"}, desc = "Lock virtual cursors"},
        },
    },
    {
        'stevearc/oil.nvim',
        ---@module 'oil'
        ---@type oil.SetupOpts,
        opts = {
            default_file_explorer = true
        },
        config = function()
            -- load the colorscheme here
            require("oil").setup({
                    default_file_explorer = true,

                    view_options = {
                        show_hidden = true
                    },
                })
        end,
        -- Optional dependencies
        dependencies = { { "nvim-mini/mini.icons", opts = {} } },
        -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
        -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
        lazy = false,
    },

}
