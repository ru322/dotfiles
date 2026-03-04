return
{
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
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup()
            --require("lspconfig").clangd.setup{}
            require("mason-lspconfig").setup({
            handlers = {
                function(server_name)
                -- この中で各LSPサーバがセットアップされる
                require("lspconfig")[server_name].setup({
                        capabilities = capabilities,
                })
                end,
            }
            })
        end,
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

        config = function()
            -- friendly-snippetsからスニペットを読み込む
            require("luasnip.loaders.from_vscode").lazy_load()

            -- nvim-cmpの設定
            local cmp = require('cmp')
            local luasnip = require('luasnip')


            cmp.setup({
            snippet = {
                expand = function(args)
                luasnip.lsp_expand(args.body)
                end,
            },
            -- 補完候補を選択するキーマッピング
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(), -- 上の候補を選択
                ['<C-n>'] = cmp.mapping.select_next_item(), -- 下の候補を選択
                ['<CR>'] = cmp.mapping.confirm({ select = true }), -- 候補を確定
                ['<Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
                end, { "i", "s" }),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
                end, { "i", "s" }),
            }),
            -- 補完ソースの定義
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
                { name = 'buffer' },
                { name = 'path' },
                -- { name = 'copilot'}
            }),
            --require('Comment').setup()

            })
        end,
    },
    {
        'numToStr/Comment.nvim',
        opts = {
            -- add any options here
        },
    },
    {
        "github/copilot.vim",
        opt={
            vim.g.copilot_no_tab_map=true,
        }
    },
    {
        'tpope/vim-surround',
    },
}
