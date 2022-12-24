local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- Install your plugins here
return packer.startup(function(use)
  
  -- My plugins here
  -- WORTH NOTING!!! *** use "user/repo" -- neovim plugins are, are just github repos with lua directories inside of them and provide a lua (or vimscript inside of a lua file) functionality that packer understands
    
  use "wbthomason/packer.nvim" -- Have packer manage itself (every time we change THIS file and SAVE it, automatically update and manage packer) this is literally the equivelant of :PackerUpdate
  use "nvim-lua/popup.nvim" -- An implementation of the Popup API from vim in Neovim (this is here because a ton of other plugins rely on this plugin)
  use "nvim-lua/plenary.nvim" -- Useful lua functions used ny lots of plugins (this is here because a ton of other plugins rely on this plugin as well)


  -- Colorschemes
  -- use "lunarvim/colorschemes" -- A bunch of colorschemes you can try out
  use "lunarvim/onedarker.nvim" -- saw this on Chris's YT channel
  use "lunarvim/darkplus.nvim" -- same as above
  use "lunarvim/tokyonight.nvim" -- same as above

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
