-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("x", "<leader>sq", function()
  vim.cmd([[normal! gv]])
  vim.cmd([[normal! :]])
  vim.api.nvim_feedkeys([[:'<,'>s/\v<()>/\1/g]], "n", true)
end, { desc = "Start :'<,'>s/ substitution with \\(\\) in visual mode" })

vim.keymap.set("n", "<leader>sw", function()
  local word = vim.fn.expand("<cWORD>")       -- captures the WORD under cursor (non-whitespace run)
  local escaped = vim.fn.escape(word, [[\/]]) -- escape slashes if present
  local command = string.format([[:%%s/\v<%s>//g]], escaped)
  vim.api.nvim_feedkeys(command, "n", true)
end, { desc = "Substitute WORD under cursor across buffer" })
