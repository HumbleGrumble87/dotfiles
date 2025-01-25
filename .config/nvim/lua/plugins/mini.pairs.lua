--disabled this plugin because when i type a fucking left paren, i mean a fucking left paren

return {
  {
    "echasnovski/mini.pairs",
    version = "*",
    enabled = true, -- Start with the plugin enabled
    lazy = false,
    config = function(_, opts)
      require("mini.pairs").setup(opts) -- Initial setup

      -- Variable to track toggle state
      local mini_pairs_enabled = true

      -- Function to toggle MiniPairs
      _G.toggle_mini_pairs = function()
        if mini_pairs_enabled then
          -- Disable mini.pairs by clearing its mappings
          -- vim.cmd("silent! unmap <buffer> <expr> <BS>")
          -- vim.cmd("silent! unmap <buffer> <expr> (")
          -- vim.cmd("silent! unmap <buffer> <expr> {")
          -- vim.cmd("silent! unmap <buffer> <expr> [")
          -- vim.cmd("silent! unmap <buffer> <expr> '")
          -- vim.cmd('silent! unmap <buffer> <expr> "')
          enabled = false
          print("Mini.pairs disabled")
        else
          -- Re-enable mini.pairs by setting it up again
          enabled = true, require("mini.pairs").setup()
          print("Mini.pairs enabled")
        end
        mini_pairs_enabled = not mini_pairs_enabled
      end

      -- Add a keybinding to toggle it (e.g., <leader>mp)
      vim.api.nvim_set_keymap("n", "<leader>mp", ":lua toggle_mini_pairs()<CR>", { noremap = true, silent = true })
    end,
  },
}
