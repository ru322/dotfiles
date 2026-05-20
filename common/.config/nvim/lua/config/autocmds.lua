local lsp = require("config.lsp")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    lsp.on_attach(event.buf)
  end,
})
