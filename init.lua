require("gmk")
vim.o.exrc = true -- Allow per project settings override with .nvim.lua
vim.o.wrap = false
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
  pattern = { 'c3', 'ruby', 'eruby', 'scss', 'css', 'html',
              'javascript', 'javascriptreact', 'yaml'},
  callback = function() vim.treesitter.start() end,
})

vim.filetype.add({
  extension = { thor = "ruby", jbuilder = "ruby" },
  filename  = { Guardfile = "ruby", Capfile = "ruby", ["packwerk.yml"] = "yaml" },
})

if vim.g.neovide then
    vim.o.guifont = "Annotation Mono Medium:h15"
end


