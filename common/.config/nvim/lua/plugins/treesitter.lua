return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    -- This plugin must not be lazy-loaded.
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- Parsers are installed on first start (asynchronously, in the background).
      -- Update them later with :TSUpdate.
      require("nvim-treesitter").install({
        "bash",
        "c",
        "cpp",
        "css",
        "fish",
        "go",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "nix",
        "python",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      })

      -- Enable treesitter highlighting and (experimental) treesitter indentation.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          local bufnr = ev.buf
          local ft = vim.bo[bufnr].filetype
          -- Defer: runtime ftplugin/indent scripts run on the same FileType event
          -- and would otherwise overwrite our indentexpr.
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(bufnr) then
              return
            end

            local lang = vim.treesitter.language.get_lang(ft)
            if not lang then
              return
            end

            -- Skip filetypes whose parser is not installed.
            local ok, loaded = pcall(vim.treesitter.language.add, lang)
            if not ok or not loaded then
              return
            end

            vim.treesitter.start(bufnr, lang)

            -- Only use treesitter indenting when the language ships an indents query,
            -- otherwise fall back to the normal indentexpr/smartindent behaviour.
            if vim.treesitter.query.get(lang, "indents") then
              vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
          end)
        end,
      })
    end,
  },
}
