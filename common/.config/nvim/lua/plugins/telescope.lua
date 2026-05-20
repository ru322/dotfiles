return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = function()
      local builtin = require("telescope.builtin")

      return {
        { "<leader>ff", builtin.find_files, desc = "Find files" },
        { "<leader>fg", builtin.live_grep, desc = "Live grep" },
        { "<leader>fb", builtin.buffers, desc = "Find buffers" },
        { "<leader>fh", builtin.help_tags, desc = "Help tags" },
        { "<leader>fr", builtin.oldfiles, desc = "Recent files" },
        { "<leader>fc", builtin.git_commits, desc = "Git commits" },
        { "<leader>fs", builtin.git_status, desc = "Git status" },
      }
    end,
  },
}
