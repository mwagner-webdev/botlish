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
--
-- Highlighting: syntax/botlish.vim beside this file (generated from the
-- compiler's word lists by tools/editor-grammars.tcl) highlights a buffer
-- at once, and the server's semantic tokens refine it once its analysis
-- answers (Neovim requests them by itself; SYNTAX-HIGHLIGHTING-MILESTONE-
-- 1.md). This file puts its own directory on the runtime path for that.

vim.filetype.add({ extension = { bot = 'botlish' } })

local here = vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2))
if here and vim.uv.fs_stat(here .. '/syntax/botlish.vim') then
  vim.opt.runtimepath:append(here)
end

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
