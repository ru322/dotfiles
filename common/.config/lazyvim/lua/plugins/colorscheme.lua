return {
  {
    "folke/tokyonight.nvim",
    -- Match kitty's tokyo_night_night theme and let the wallpaper show through,
    -- floats (pickers, hover, completion) included.
    opts = {
      style = "night",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
}
