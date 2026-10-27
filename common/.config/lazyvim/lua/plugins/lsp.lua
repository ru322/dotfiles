return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Let clangd find the Nix g++ system headers.
      local clangd = opts.servers.clangd or {}
      clangd.cmd = vim.list_extend(vim.deepcopy(clangd.cmd or { "clangd" }), {
        "--query-driver=/home/koyama/.nix-profile/bin/g++",
      })
      opts.servers.clangd = clangd
    end,
  },
}
