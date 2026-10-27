return {
  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
    init = function()
      vim.g.transparent_enabled = true
    end,
    opts = {
      extra_groups = {
        "NeoTreeNormal",
        "NeoTreeNormalNC",
        "NeoTreeEndOfBuffer",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "solarized",
    },
  },
}
