return {
  "dkarter/bullets.vim",
  ft = { "markdown", "text" },
  config = function()
    vim.g.bullets_enabled_file_types = { "markdown", "text" }

    -- Optional quality-of-life tweaks
    vim.g.bullets_delete_last_bullet_if_empty = 1
    vim.g.bullets_auto_indent_after_colon = 1
  end,
}
