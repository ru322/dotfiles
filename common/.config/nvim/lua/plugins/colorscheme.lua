return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    -- Match kitty's tokyo_night_night theme and let the wallpaper show through,
    -- floats (Telescope, hover, completion) included.
    opts = {
      style = "night",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
}
