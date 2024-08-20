--[[
--The purpose of this plugin is to fix autoselecting a completion just because one is available.
--This happens when I hit <CR>, with the intent of getting a newline,
--But if there's a an autocompletion suggestion, and there usually is,
--Then I get a useless autocompletion instead.
--
--This functionality is part of nvim-cmp and it has it's own lua file of the same name.
--However, in order to get all this to work (and it was quite touchy),
--I had to do a lot of dicking around. We wanted three things to happen:
--  1) disable autocompletion unless explicitly tabbed for
--  2) disable ghost_text, aka autocomplete preview, annoying to say the least
--  3) enable <Tab> expansion of snippets, which kept breaking during all this
--
--Here's all the relevant shit:
--https://www.reddit.com/r/neovim/comments/1af6h96/what_is_the_source_of_this_ghost_text/
--https://www.lazyvim.org/plugins/coding
--https://www.lazyvim.org/configuration/recipes
--https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#super-tab-like-mapping
--]]

return {
  {
    "hrsh7th/nvim-cmp",
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            -- You could replace select_next_item() with confirm({ select = true }) to get VS Code autocompletion behavior
            cmp.select_next_item()
          elseif vim.snippet.active({ direction = 1 }) then
            vim.schedule(function()
              vim.snippet.jump(1)
            end)
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif vim.snippet.active({ direction = -1 }) then
            vim.schedule(function()
              vim.snippet.jump(-1)
            end)
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<CR>"] = cmp.mapping({
          i = function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
              fallback()
            end
          end,
          s = cmp.mapping.confirm({ select = true }),
          c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
        }),
      })
    end,
  }
}
