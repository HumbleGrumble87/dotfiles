-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("x", "<leader>sq", function()
  vim.cmd([[normal! gv]])
  vim.cmd([[normal! :]])
  vim.api.nvim_feedkeys([[:'<,'>s/\v<()>/\1]], "n", true)
end, { desc = "Start :'<,'>s/ substitution with \\(\\) in visual mode" })
