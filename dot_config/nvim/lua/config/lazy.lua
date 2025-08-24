-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
    {
        "maxmx03/solarized.nvim",
        lazy = false,
        opts={},
        config = function(_,opts)
          vim.o.termguicolors = true
          vim.o.background = 'dark'
          require('solarized').setup(opts)
          vim.cmd.colorscheme 'solarized'
        end
    },
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy=false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",       
        },
        config = function()
            require("nvim-tree").setup {}
        end,
    },
    {
        'numToStr/Comment.nvim',
        opt={}
    },
    {
        'akinsho/bufferline.nvim',
        version="*",
        dependencies = 'nvim-tree/nvim-web-devicons'
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = {'nvim-tree/nvim-web-devicons'}
    },
    {
        'kevinhwang91/nvim-bqf'
    },
    {
        'windwp/nvim-autopairs',
        event = "INsertEnter",
        config = true
    },
    {
        "mason-org/mason.nvim",
        opts = {}
    },
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {
            ensure_installed = { "clangd" },
        },
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        },
    },
    {
      "hrsh7th/nvim-cmp",
      -- event = "InsertEnter", -- 起動高速化のための遅延読み込み
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",
      },
    },
})
