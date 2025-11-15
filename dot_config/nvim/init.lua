vim.opt.number = true
vim.opt.ignorecase = true
vim.opt.autoindent = true
vim.opt.tabstop=4
vim.opt.softtabstop=4
vim.opt.shiftwidth=4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.clipboard:append{'unnamed,unnamedplus'}
colorscheme = tokyonight



vim.keymap.set('n', '<C-n>',vim.cmd.NvimTreeToggle)
vim.keymap.set('n', '<S-Tab>', '<<')
vim.keymap.set('n', '<Tab>', '>>')
vim.keymap.set('i', '<S-Tab>', '<C-d>')
vim.keymap.set('i', 'jj', '<Esc>')
require("config.lazy")
--[[
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
]]

-- LSPサーバアタッチ時の処理
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ctx)
    local set = vim.keymap.set
    set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { buffer = true })
    set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { buffer = true })
    set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { buffer = true })
    set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", { buffer = true })
    set("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", { buffer = true })
    set("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", { buffer = true })
    set("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", { buffer = true })
    set("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", { buffer = true })
    set("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", { buffer = true })
    set("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", { buffer = true })
    set("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", { buffer = true })
    set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", { buffer = true })
    set("n", "<space>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", { buffer = true })
    set("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", { buffer = true })
    set("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", { buffer = true })
    set("n", "<space>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", { buffer = true })
    set("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", { buffer = true })
  end,
})
--[[
-- friendly-snippetsからスニペットを読み込む
require("luasnip.loaders.from_vscode").lazy_load()
]]

--[[
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
  }),
  --require('Comment').setup()

})
]]


