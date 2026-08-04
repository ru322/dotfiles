local lsp = require("config.lsp")

return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = { "clangd" },
    },
    config = function(_, opts)
      vim.lsp.config("*", {
        capabilities = lsp.capabilities(),
        on_attach = function(_, bufnr)
          lsp.on_attach(bufnr)
        end,
      })

      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--query-driver=/home/koyama/.nix-profile/bin/g++",
        },
      })

      require("mason").setup()
      require("mason-lspconfig").setup(opts)
    end,
  },
}
