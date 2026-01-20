vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use { 'wbthomason/packer.nvim' }

  use {
	  'nvim-telescope/telescope.nvim', tag = '*',
	  requires = { { 'nvim-lua/plenary.nvim' } }
  }

  use { 'ellisonleao/gruvbox.nvim' }

  use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
  }

  use ('https://git.sr.ht/~foosoft/argonaut.nvim')

  use {
      'numToStr/Comment.nvim',
      config = function()
          require('Comment').setup()
      end
  }

  if packer_bootstrap then
      require('packer').sync()
  end

end)


