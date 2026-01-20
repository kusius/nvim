local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require("gmk")
vim.opt.clipboard = "unnamedplus"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4        -- Number of spaces a <Tab> counts for
vim.opt.shiftwidth = 4     -- Number of spaces for each indentation level
vim.opt.expandtab = true   -- Convert tabs to spaces
vim.opt.softtabstop = 4    -- Number of spaces for <Tab> in insert mode
vim.opt.ignorecase = true  -- Ignore case in searches
vim.opt.smartcase = true   -- Override ignorecase if search contains uppercase

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c3' },
  callback = function() vim.treesitter.start() end,
})
