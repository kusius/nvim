return {
    {
        "https://codeberg.org/vi6jm/scry.nvim",
        config = function()
            require("scry").setup()
        end,
    },
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
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ':TSUpdate',
        config = function()
            require("nvim-treesitter").install {
                "kotlin", "java",
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
            formatters_by_ft = {
                c = { "clang-format" },
                cpp = { "clang-format" },
                -- gq (via formatexpr, set below) runs ktlint --format. It fixes style only:
                -- naming is never auto-fixed, nvim-lint keeps reporting those.
                kotlin = { "ktlint" },
            },
            formatters = {
                ["clang-format"] = {
                    command = "clang-format",
                },
                ktlint = {
                    -- ktlint exits 1 when a file still has unfixable violations (naming, say)
                    -- yet it prints the formatted code all the same. Without this, conform
                    -- discards that output and the file silently stays unformatted.
                    exit_codes = { 0, 1 },
                    -- conform's built-in args pass --stdin without --stdin-path, so ktlint
                    -- resolves .editorconfig from :pwd instead of the file and reformats
                    -- against default rules. Pass the real path, and the compose ruleset.
                    args = function(_, ctx)
                        local args = { '--format', '--stdin', '--log-level=none', '--stdin-path=' .. ctx.filename }
                        local root = vim.fs.root(ctx.filename, { 'settings.gradle.kts', 'settings.gradle', 'pom.xml', '.git' })
                        for _, jar in ipairs({
                            root and (root .. '/.ktlint/ktlint-compose.jar'),
                            vim.fn.expand('~/.ktlint/ktlint-compose.jar'),
                        }) do
                            if jar and vim.uv.fs_stat(jar) then
                                table.insert(args, '--ruleset=' .. jar)
                                break
                            end
                        end
                        return args
                    end,
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
        "maelwalser/oil-bar.nvim",
        dependencies = { "stevearc/oil.nvim" },
        opts = {
            keymap = "<leader>p" 
        },
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            -- Latest LSP $/progress message (kotlin-lsp: Importing, Indexing, ...),
            -- cleared a few seconds after the task ends.
            local lsp_progress = ''
            vim.api.nvim_create_autocmd('LspProgress', {
                group = vim.api.nvim_create_augroup('LualineLspProgress', { clear = true }),
                callback = function(ev)
                    local v = ev.data.params.value
                    local client = vim.lsp.get_client_by_id(ev.data.client_id)
                    local name = client and client.name or 'lsp'
                    if v.kind == 'end' then
                    lsp_progress = name .. ': ' .. (v.title or '') .. ' done'
                    local done = lsp_progress
                    vim.defer_fn(function()
                        if lsp_progress == done then lsp_progress = ''; require('lualine').refresh() end
                    end, 3000)
                else
                    local parts = { name .. ':', v.title, v.message, v.percentage and (v.percentage .. '%%') }
                    lsp_progress = table.concat(vim.tbl_filter(function(p) return p and p ~= '' end, parts), ' ')
                end
                require('lualine').refresh()
            end,
        })

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
                lualine_x = { function() return lsp_progress end, 'filetype' },
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
    -- ktlint, so Kotlin naming is judged by the compose ruleset instead of kotlin-lsp:
    -- the server flags every @Composable as "should start with a lowercase letter"
    -- (Kotlin/kotlin-lsp#191) and offers no way to disable an inspection (#52), so that
    -- diagnostic is filtered in gmk/lsp.lua and ktlint reports naming correctly here.
    'mfussenegger/nvim-lint',
    ft = { 'kotlin' },
    config = function()
        local lint = require('lint')

        -- Per-project ruleset first (nutrichum downloads its own), else the shared copy.
        -- '.ktlint' is deliberately not a root marker: ~/.ktlint would then resolve every
        -- project's root to $HOME.
        local function compose_ruleset(fname)
            local root = vim.fs.root(fname, { 'settings.gradle.kts', 'settings.gradle', 'pom.xml', '.git' })
            for _, jar in ipairs({
                root and (root .. '/.ktlint/ktlint-compose.jar'),
                vim.fn.expand('~/.ktlint/ktlint-compose.jar'),
            }) do
                if jar and vim.uv.fs_stat(jar) then return jar end
            end
        end

        -- A function, not a table: the ruleset path is per buffer. stdin is off so ktlint
        -- resolves the project's .editorconfig next to the file, whatever :pwd happens to be.
        lint.linters.ktlint = function()
            local args = { '--reporter=json', '--log-level=none' }
            local jar = compose_ruleset(vim.api.nvim_buf_get_name(0))
            if jar then table.insert(args, '--ruleset=' .. jar) end
            return {
                cmd = 'ktlint',
                stdin = false,
                append_fname = true,
                stream = 'stdout',
                ignore_exitcode = true,
                args = args,
                parser = function(output)
                    if output == '' then return {} end
                    local ok, report = pcall(vim.json.decode, output)
                    if not ok or type(report) ~= 'table' then return {} end
                    local diagnostics = {}
                    for _, file in ipairs(report) do
                        for _, e in ipairs(file.errors or {}) do
                            -- Keep the rule id: 'compose:naming-check' explains itself in a
                            -- way the bare message does not.
                            table.insert(diagnostics, {
                                lnum = math.max((e.line or 1) - 1, 0),
                                col = math.max((e.column or 1) - 1, 0),
                                end_lnum = math.max((e.line or 1) - 1, 0),
                                end_col = math.max((e.column or 1) - 1, 0),
                                message = e.message:gsub('%s+$', '') .. (e.rule and (' (' .. e.rule .. ')') or ''),
                                code = e.rule,
                                severity = vim.diagnostic.severity.WARN,
                                source = 'ktlint',
                            })
                        end
                    end
                    return diagnostics
                end,
            }
        end

        lint.linters_by_ft = vim.tbl_extend('force', lint.linters_by_ft or {}, { kotlin = { 'ktlint' } })

        vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
            group = vim.api.nvim_create_augroup('KtlintOnWrite', { clear = true }),
            pattern = '*.kt',
            desc = 'Lint Kotlin with ktlint + compose ruleset',
            callback = function() lint.try_lint() end,
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
