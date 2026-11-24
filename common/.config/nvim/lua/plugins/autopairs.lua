return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      -- Use treesitter to decide whether a pair is safe to auto-close.
      check_ts = true,
      -- <M-e> wraps the next text in a pair.
      fast_wrap = {},
      disable_filetype = { "TelescopePrompt" },
    },
  },
}
