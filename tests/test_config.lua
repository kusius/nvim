-- Tests for this Neovim config, using mini.test.
--
--   Run everything:  ./tests/run.sh
--   Docs:            :h mini.test   (or https://github.com/echasnovski/mini.test)
--
-- These run *inside* a Neovim that has already sourced the whole config, so
-- they can inspect the live editor directly: vim.o, vim.g, autocmds, lazy's
-- plugin list, and so on.
--
-- Adding a test is one line plus a function:
--
--   T["options"]["wraps nothing"] = function()
--     MiniTest.expect.equality(vim.o.wrap, false)
--   end
--
-- Useful expectations (all give a readable diff when they fail):
--   MiniTest.expect.equality(observed, expected)
--   MiniTest.expect.no_equality(observed, unexpected)
--   MiniTest.expect.error(fn, "pattern")
--   MiniTest.expect.no_error(fn)
--   MiniTest.skip("reason")            -- skip the current case

local MiniTest = require("mini.test")
local expect = MiniTest.expect

local T = MiniTest.new_set()

-- Any line Neovim considers an error, gathered from :messages. Errors raised
-- inside an autocmd callback never propagate to the caller, so this is the
-- only way to notice them from in-process.
local function error_messages()
  local out = vim.api.nvim_exec2("messages", { output = true }).output or ""
  local bad = {}
  for line in out:gmatch("[^\n]+") do
    if line:match("^E%d+:") or line:match("Error") or line:match("^W%d+:") then
      table.insert(bad, line)
    end
  end
  return bad
end

T["startup"] = MiniTest.new_set()

T["startup"]["reports no errors"] = function()
  expect.equality(error_messages(), {})
end

T["startup"]["leaves v:errmsg empty"] = function()
  expect.equality(vim.v.errmsg, "")
end

T["startup"]["loads every gmk module"] = function()
  for _, mod in ipairs({ "gmk", "gmk.lazy", "gmk.remap", "gmk.lsp" }) do
    expect.no_equality(package.loaded[mod], nil)
  end
end

T["plugins"] = MiniTest.new_set()

T["plugins"]["resolve without spec errors"] = function()
  -- lazy leaves this nil when the spec is clean, and sets it to true on error.
  expect.equality(require("lazy.core.config").spec.errors or false, false)
  expect.equality(#require("lazy").plugins() > 0, true)
end

T["plugins"]["are all installed on disk"] = function()
  local missing = {}
  for _, plugin in ipairs(require("lazy").plugins()) do
    if not (vim.uv or vim.loop).fs_stat(plugin.dir) then
      table.insert(missing, plugin.name)
    end
  end
  expect.equality(missing, {})
end

T["plugins"]["marked as start plugins are loaded"] = function()
  local not_loaded = {}
  for _, plugin in ipairs(require("lazy").plugins()) do
    if plugin.lazy == false and not plugin._.loaded then
      table.insert(not_loaded, plugin.name)
    end
  end
  expect.equality(not_loaded, {})
end

T["options"] = MiniTest.new_set()

T["options"]["set the leader keys"] = function()
  expect.equality(vim.g.mapleader, ",")
  expect.equality(vim.g.maplocalleader, "\\")
end

T["options"]["activate a colorscheme"] = function()
  expect.no_equality(vim.g.colors_name, nil)
  expect.no_equality(vim.g.colors_name, "")
end

T["options"]["apply the indent settings"] = function()
  expect.equality(vim.o.relativenumber, true)
  expect.equality(vim.o.expandtab, true)
  expect.equality(vim.o.shiftwidth, 4)
  expect.equality(vim.o.wrap, false)
end

-- The servers themselves are not installed in CI, so only the registration is
-- checked. parametrize runs the same case once per server, and reports each
-- one separately.
T["lsp"] = MiniTest.new_set({
  parametrize = { { "ruby_lsp" }, { "luals" }, { "clangd" }, { "kotlin_lsp" }, { "c3lsp" }, { "gopls" } },
})

T["lsp"]["server is registered with a command"] = function(server)
  local cfg = vim.lsp.config[server]
  expect.no_equality(cfg, nil)
  expect.no_equality(cfg.cmd, nil)
end

T["filetypes"] = MiniTest.new_set()

T["filetypes"]["map ruby-ish extensions"] = function()
  expect.equality(vim.filetype.match({ filename = "lib/tasks/foo.thor" }), "ruby")
  expect.equality(vim.filetype.match({ filename = "app/views/x.jbuilder" }), "ruby")
end

T["filetypes"]["map ruby-ish filenames"] = function()
  expect.equality(vim.filetype.match({ filename = "Guardfile" }), "ruby")
  expect.equality(vim.filetype.match({ filename = "Capfile" }), "ruby")
  expect.equality(vim.filetype.match({ filename = "packwerk.yml" }), "yaml")
end

-- Guards the RestoreCursorPosition autocmd in init.lua. Each case gets a fresh
-- 20 line file, and the buffer is cleaned up afterwards.
local file
T["cursor restore"] = MiniTest.new_set({
  hooks = {
    pre_case = function()
      file = vim.fn.tempname()
      local lines = {}
      for i = 1, 20 do
        lines[i] = "line " .. i
      end
      vim.fn.writefile(lines, file)
    end,
    post_case = function()
      vim.cmd("silent! bdelete!")
      vim.fn.delete(file)
    end,
  },
})

T["cursor restore"]["registers the autocmd"] = function()
  local autocmds = vim.api.nvim_get_autocmds({
    group = "RestoreCursorPosition",
    event = "BufReadPost",
  })
  expect.equality(#autocmds > 0, true)
end

T["cursor restore"]["returns to the last position on reopen"] = function()
  vim.cmd.edit(vim.fn.fnameescape(file))
  vim.api.nvim_win_set_cursor(0, { 12, 0 })
  vim.cmd('normal! m"') -- the " mark is what the autocmd reads
  vim.cmd("bdelete!")

  vim.cmd.edit(vim.fn.fnameescape(file))
  expect.equality(vim.api.nvim_win_get_cursor(0)[1], 12)
end

T["cursor restore"]["ignores a mark past the end of a shrunken file"] = function()
  vim.cmd.edit(vim.fn.fnameescape(file))
  vim.api.nvim_win_set_cursor(0, { 20, 0 })
  vim.cmd('normal! m"')
  vim.cmd("bdelete!")

  vim.fn.writefile({ "line 1", "line 2", "line 3" }, file)
  vim.cmd("messages clear")

  expect.no_error(function()
    vim.cmd.edit(vim.fn.fnameescape(file))
  end)
  expect.equality(error_messages(), {})
  expect.equality(vim.api.nvim_win_get_cursor(0)[1] <= vim.api.nvim_buf_line_count(0), true)
end

return T
