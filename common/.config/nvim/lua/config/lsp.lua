local M = {}

function M.capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")

  if ok then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  return capabilities
end

function M.on_attach(bufnr)
  local opts = { buffer = bufnr }
  local set = vim.keymap.set

  set("n", "gD", vim.lsp.buf.declaration, opts)
  set("n", "gd", vim.lsp.buf.definition, opts)
  set("n", "K", vim.lsp.buf.hover, opts)
  set("n", "gi", vim.lsp.buf.implementation, opts)
  set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
  set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
  set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
  set("n", "<space>D", vim.lsp.buf.type_definition, opts)
  set("n", "<space>rn", vim.lsp.buf.rename, opts)
  set("n", "<space>ca", vim.lsp.buf.code_action, opts)
  set("n", "gr", vim.lsp.buf.references, opts)
  set("n", "<space>f", function()
    vim.lsp.buf.format({ async = true })
  end, opts)
  set("n", "<space>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)
  set("n", "<space>e", vim.diagnostic.open_float, opts)
  set("n", "[d", vim.diagnostic.goto_prev, opts)
  set("n", "]d", vim.diagnostic.goto_next, opts)
  set("n", "<space>q", vim.diagnostic.setloclist, opts)
end

return M
