return {
  {
    "numToStr/Comment.nvim",
    opts = {},
    config = function(_, opts)
      require("Comment").setup(opts)

      local api = require("Comment.api")
      local map_opts = { desc = "Toggle comment", silent = true }
      local visual_toggle = '<ESC><cmd>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>'

      vim.keymap.set("n", "<C-_>", api.toggle.linewise.current, map_opts)
      vim.keymap.set("x", "<C-_>", visual_toggle, map_opts)
      vim.keymap.set("n", "<C-/>", api.toggle.linewise.current, map_opts)
      vim.keymap.set("x", "<C-/>", visual_toggle, map_opts)
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },
  {
    "tpope/vim-surround",
  },
  {
    "github/copilot.vim",
    init = function()
      vim.g.copilot_no_tab_map = true
    end,
  },
}
