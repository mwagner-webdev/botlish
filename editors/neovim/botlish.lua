-- botlish.lua -- Botlish's language server in Neovim's built-in LSP client
-- (Neovim 0.10 or later; LSP-MILESTONE-1.md, "Editors").
--
-- Load it from your init.lua (dofile('/path/to/botlish.lua')) or put it in a
-- plugin/ directory of your runtime path. `.bot` files get the filetype
-- botlish, and every Botlish buffer is attached to one language server,
-- started as
--
--   botlish -lsp                              (the single executable), or
--   vim.g.botlish_lsp_cmd                     when set, for example
--     { 'tclsh9.0', '/path/to/botlish/main.tcl', '-lsp' }   (a checkout)
--
-- One server serves every Botlish buffer of the session: it works out which
-- open file is a program and which a module itself, so a standard-library
-- module opened by go-to-definition is answered from the program that
-- imports it. Then the usual keys apply: K (hover), gd or
-- vim.lsp.buf.definition(), grr or vim.lsp.buf.references(), and the
-- diagnostics as Neovim shows them.

vim.filetype.add({ extension = { bot = 'botlish' } })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'botlish',
  callback = function(args)
    vim.lsp.start({
      name = 'botlish',
      cmd = vim.g.botlish_lsp_cmd or { 'botlish', '-lsp' },
      -- A program's application root is its own file's directory.
      root_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(args.buf)),
    }, {
      bufnr = args.buf,
      reuse_client = function(client, config)
        return client.name == config.name
      end,
    })
  end,
})
