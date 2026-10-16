local lsp = require("config.lsp")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client then
      lsp.on_attach(client, event.buf)
    end
  end,
})
