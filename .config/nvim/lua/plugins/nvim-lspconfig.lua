--im disabling this plugin for json only because it requires npm and that may be resource intensive
return {
{
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      jsonls = {
        mason = false,
      },
    },
  },
},
}
