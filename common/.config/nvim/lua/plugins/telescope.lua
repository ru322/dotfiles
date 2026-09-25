local commands = {
  files = "find_files",
  grep = "live_grep",
  buffers = "buffers",
  help = "help_tags",
  recent = "oldfiles",
  commits = "git_commits",
  status = "git_status",
}

return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    init = function()
      for command, picker in pairs(commands) do
        -- Only expand a complete command, never text in a search or argument.
        vim.keymap.set("ca", command, function()
          if vim.fn.getcmdtype() == ":"
            and vim.fn.getcmdline() == command
            and vim.fn.getcmdpos() == #command + 1
          then
            return "Telescope " .. picker
          end
          return command
        end, { expr = true, desc = "Telescope " .. picker })
      end
    end,
    opts = {
      pickers = {
        find_files = { hidden = true },
        live_grep = { additional_args = { "--hidden" } },
      },
    },
  },
}
