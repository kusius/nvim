-- Generic Ruby `rdbg` (debug gem) attach over DAP.
--
--   require("dap_rdbg").setup(dap, {
--     port = 12345,                  -- number, or function returning a number
--                                    -- (or a coroutine, see nvim-dap docs)
--     remote_root = "/app",          -- optional: project root as the debuggee sees it
--     name = "Attach (rdbg)",        -- optional
--   })
--
-- With `remote_root`, rdbg maps its paths to the local project root (the nearest
-- ancestor of the current buffer with a .git entry) through `localfsMap`.
local M = {}

function M.git_root()
    local anchor = vim.api.nvim_buf_get_name(0)
    if anchor == "" then
        anchor = vim.fn.getcwd()
    end
    return vim.fs.root(anchor, ".git") or vim.fn.getcwd()
end

function M.setup(dap, opts)
    opts = opts or {}

    dap.adapters.rdbg = function(callback, config)
        callback({ type = "server", host = "127.0.0.1", port = config.debugPort })
    end

    local config = {
        type = "rdbg",
        request = "attach",
        name = opts.name or "Attach (rdbg)",
        debugPort = opts.port or 12345,
    }
    if opts.remote_root then
        config.localfsMap = function()
            return opts.remote_root .. ":" .. M.git_root()
        end
    end

    dap.configurations.ruby = dap.configurations.ruby or {}
    table.insert(dap.configurations.ruby, config)
end

return M
