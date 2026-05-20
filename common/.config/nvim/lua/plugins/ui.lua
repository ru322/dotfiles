return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "kevinhwang91/nvim-bqf",
  },
}
