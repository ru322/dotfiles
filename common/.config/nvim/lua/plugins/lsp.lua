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
      ensure_installed = { "clangd", "basedpyright", "ruff", "vtsls" },
      -- basedpyright replaces pylsp; avoid two servers on Python buffers.
      automatic_enable = { exclude = { "pylsp" } },
    },
    config = function(_, opts)
      vim.lsp.config("*", {
        capabilities = lsp.capabilities(),
      })

      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--query-driver=/home/koyama/.nix-profile/bin/g++",
        },
      })

      -- Type checking and hover come from basedpyright; ruff only lints and formats.
      vim.lsp.config("ruff", {
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
        end,
      })

      local ts_inlay_hints = {
        parameterNames = { enabled = "literals" },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = false },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      }

      vim.lsp.config("vtsls", {
        settings = {
          typescript = { inlayHints = ts_inlay_hints },
          javascript = { inlayHints = ts_inlay_hints },
        },
      })

      require("mason").setup()
      require("mason-lspconfig").setup(opts)
    end,
  },
}
