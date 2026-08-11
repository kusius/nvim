return {
    {
        "0xKitsune/pr.nvim",
        -- or use a local path:
        -- dir = "~/path/to/pr.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim", -- optional
        },
        config = function()
            require("pr").setup()
        end,
    },
    {
        "lewis6991/gitsigns.nvim",
        lazy = false,
        config = function()
            require("gitsigns").setup {
                auto_attach = true,
                current_line_blame = true,
            }
        end,
    },
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
            -- vim.cmd([[colorscheme gruvbox]])
            -- vim.o.background = "dark"
        end,
    },
    {
        "Aejkatappaja/cendre",
        lazy = false,
        priority = 1000,
        config = function()
            require("cendre").setup({
                background = "cendre", -- "hard" | "medium" | "soft"
                italic_virtual_text = true,
            })
            vim.cmd.colorscheme("cendre")
        end,
    },
    {
        "savq/melange-nvim",
        config = function()
            -- vim.cmd([[colorscheme melange]])
            -- vim.o.background = "dark"
        end,
    },

    {
        "ember-theme/nvim",
        name = "ember",
        priority = 1000,
        config = function()
            require("ember").setup({
                variant = "ember-soft", -- "ember" | "ember-soft" | "ember-light"
            })
            -- vim.cmd([[colorscheme ember-soft]])
            -- vim.o.background = "dark"
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
                "json",
                "ruby", "embedded_template", "html", "scss", "css",
                "javascript", "yaml", "markdown", "markdown_inline",
            }
        end,
    },

    {
        "https://git.sr.ht/~foosoft/argonaut.nvim"
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
                skip_confirm_for_simple_edits = true,

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

    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require("lualine").setup({
                winbar = {
                    lualine_c = { { 'filename', path = 0, file_status = true} },
                },
                inactive_winbar = {
                    lualine_c = { { 'filename', path = 0, file_status = true } },
                },
                tabline = {
                },
                -- bottom
                sections = {
                    lualine_a = {'mode'},
                    lualine_b = {'diagnostics'},
                    lualine_c = {'branch'},
                    lualine_x = {'filetype'},
                    lualine_y = {'progress'},
                    lualine_z = {'location'}
                },
                inactive_sections = {
                    lualine_c = {},
                    lualine_x = {}
                }
            })
        end,
    },

    {
        'saghen/blink.cmp',
        -- optional: provides snippets for the snippet source
        dependencies = { 'rafamadriz/friendly-snippets' },
        -- use a release tag to download pre-built binaries
        version = '1.*',
        opts = {
            -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
            -- 'super-tab' for mappings similar to vscode (tab to accept)
            -- 'enter' for enter to accept
            -- 'none' for no mappings
            --
            -- All presets have the following mappings:
            -- C-space: Open menu or open docs if already open
            -- C-n/C-p or Up/Down: Select next/previous item
            -- C-e: Hide menu
            -- C-k: Toggle signature help (if signature.enabled = true)
            --
            -- See :h blink-cmp-config-keymap for defining your own keymap
            keymap = { 
                preset = 'default',
                ['<C-S-i>'] = { 'show', 'show_documentation', 'hide_documentation' },
            },

            appearance = {
                nerd_font_variant = 'mono'
            },

            completion = {
                menu = {
                    auto_show = false
                },
                documentation = {auto_show = false}
            },

            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
            },

            fuzzy = { implementation = "prefer_rust_with_warning" }
        },
        opts_extend = { "sources.default" }
    }
}
