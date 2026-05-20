return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<C-\>]],
        direction = "float",
        float_opts = {
          border = "curved",
        },
        shade_terminals = true,
      })
    end,
  },
}
