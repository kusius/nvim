return  {
    {
        "rcarriga/nvim-dap-ui", 
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio"
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- Setup UI 
            dapui.setup()

            -- Auto open/close UI with debug session
            dap.listeners.after.event_initialized["dapui_config"] =
            function() dapui.open() end

            dap.listeners.before.event_terminated["dapui_config"] =
            function() dapui.close() end

            dap.listeners.before.event_exited["dapui_config"] =
            function() dapui.close() end

            -- C/C++ adapter: lldb-dap (LLVM's official DAP server, via Homebrew llvm).
            -- Switched off codelldb because of post-continue breakpoint flakiness on macOS.
            dap.adapters["lldb-dap"] = {
                type = "executable",
                command = "/opt/homebrew/opt/llvm/bin/lldb-dap",
                name = "lldb-dap",
            }

            local lldb_init_commands = {
                "settings set target.process.follow-fork-mode child",
                "settings set target.debug-file-search-paths ./build",
                "settings set target.process.stop-on-sharedlibrary-events false",
            }

            -- Fallback for projects without a .vscode/launch.json
            dap.configurations.cpp = {
                {
                    name = "Launch (pick binary)",
                    type = "lldb-dap",
                    request = "launch",
                    program = function()
                        return vim.fn.input(
                            "Binary: ",
                            vim.fn.getcwd() .. "/",
                            "file"
                        )
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    initCommands = lldb_init_commands,
                },
            }

            -- Same launch config for C (dap.configurations is keyed by filetype)
            dap.configurations.c = dap.configurations.cpp

            -- Per-project launch configs live in <root>/.vscode/launch.json.
            -- nvim-dap's built-in provider only ever looks at
            -- `getcwd()/.vscode/launch.json`, and expands ${workspaceFolder} to
            -- getcwd() as well. That breaks when editing a vendored subrepo (say
            -- external/wasm-micro-runtime) whose launch.json belongs to the outer
            -- project root. So we replace the provider with one that walks upward
            -- for the file and anchors ${workspaceFolder} to wherever it was found.

            -- Nearest ancestor of the current buffer (or cwd) holding .vscode/launch.json
            local function find_launchjs(bufnr)
                local anchor = vim.api.nvim_buf_get_name(bufnr or 0)
                if anchor == "" or not vim.uv.fs_stat(anchor) then
                    anchor = vim.fn.getcwd()
                end
                local root = vim.fs.root(anchor, function(name, path)
                    return name == ".vscode"
                        and vim.uv.fs_stat(path .. "/.vscode/launch.json") ~= nil
                end)
                if root then
                    return root, root .. "/.vscode/launch.json"
                end
            end

            -- In-place so metatables set by dap.ext.vscode (${input:...}) survive
            local function substitute(tbl, root)
                local basename = vim.fs.basename(root)
                for key, value in pairs(tbl) do
                    if type(value) == "string" then
                        value = value:gsub("%${workspaceFolder}", function()
                            return root
                        end)
                        tbl[key] = (value:gsub("%${workspaceFolderBasename}", function()
                            return basename
                        end))
                    elseif type(value) == "table" then
                        substitute(value, root)
                    end
                end
            end

            dap.providers.configs["dap.launch.json"] = function(bufnr)
                local root, path = find_launchjs(bufnr)
                if not root then
                    return {}
                end
                local ok, configs = pcall(require("dap.ext.vscode").getconfigs, path)
                if not ok then
                    vim.notify(
                        "Can't read " .. path .. ":\n" .. tostring(configs),
                        vim.log.levels.WARN,
                        { title = "DAP" }
                    )
                    return {}
                end
                for _, config in ipairs(configs) do
                    substitute(config, root)
                    if config.type == "lldb-dap" then
                        if config.initCommands == nil then
                            config.initCommands = lldb_init_commands
                        end
                        if config.cwd == nil then
                            config.cwd = root
                        end
                    end
                end
                return configs
            end

            -- Keymap
            vim.keymap.set("n", "<F5>",  dap.continue)
            vim.keymap.set("n", "<leader>b", function() dap.toggle_breakpoint() end)
            vim.keymap.set("n", "<F10>", dap.step_over)
            vim.keymap.set("n", "<F11>", dap.step_into)
            vim.keymap.set("n", "<F12>", dap.step_out)
            vim.keymap.set("n", "<leader>du", dapui.toggle)
            -- evaluate expression under cursor
            vim.keymap.set("n", "<leader>de", dapui.eval)
        end,
    }
}
