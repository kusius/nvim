vim.keymap.set("n", "<leader>pv", "<CMD>Oil<CR>")
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" } )
vim.keymap.set("n", "gb", "<C-o>", { desc = "Go back to previous position" })
vim.keymap.set("n", "gf", "<C-i>", { desc = "Go forward in jump list" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
vim.keymap.set("n", "<leader>a", ':<c-u>ArgonautToggle<cr>', {noremap = true, silent = true})
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.setqflist, { desc = "Show all diagnostics" })

-- quickfix: <CR> jumps the other window to the entry but keeps focus on the list
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function(ev)
    vim.keymap.set("n", "<CR>", "<CR><C-w>p", { buffer = ev.buf, desc = "Go to entry, stay in quickfix" })
    vim.keymap.set("n", "o", "<CR>", { buffer = ev.buf, remap = true, desc = "Go to entry and focus it" })
  end,
})

-- lua (yog specific)
vim.keymap.set("n", "<leader>ta", "<CMD>A<CR>",  { desc = "Rails: alternate (impl <-> spec)" })
vim.keymap.set("n", "<leader>tv", "<CMD>AV<CR>", { desc = "Rails: alternate in vsplit" })

-- toggleterm
vim.keymap.set("t", "<C-q>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Hand the current file and cursor to Android Studio, for what it still does better:
-- Compose previews, profiler, layout inspector. The Toolbox 'studio' launcher reuses a
-- running instance, so this focuses the open window instead of starting a second IDE.
-- (The documented HTTP API on :63342 answers 404 for /api/file here, hence the CLI.)
vim.api.nvim_create_user_command("OpenInStudio", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Buffer has no file to open", vim.log.levels.ERROR)
    return
  end
  if vim.fn.executable("studio") == 0 then
    vim.notify("'studio' launcher not on PATH (JetBrains Toolbox installs it)", vim.log.levels.ERROR)
    return
  end
  if vim.bo.modified then
    vim.notify("Buffer has unsaved changes; Studio shows the file on disk", vim.log.levels.WARN)
  end

  local pos = vim.api.nvim_win_get_cursor(0)
  vim.system(
    { "studio", "--line", tostring(pos[1]), "--column", tostring(pos[2] + 1), file },
    { detach = true },
    function(res)
      if res.code ~= 0 then
        vim.schedule(function()
          vim.notify("studio exited " .. res.code .. ": " .. (res.stderr or ""), vim.log.levels.ERROR)
        end)
      end
    end
  )
end, { desc = "Open current file at cursor in Android Studio" })

vim.api.nvim_create_user_command("Makes", function(opts)
vim.cmd("silent make " .. opts.args .. " | redraw!")
if not vim.tbl_isempty(vim.fn.getqflist()) then
  vim.cmd("copen") -- open and focus the quickfix window
end
end, { nargs = "*", desc = "Compile silently and focus quickfix" })
