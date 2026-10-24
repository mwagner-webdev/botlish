-- lsp-neovim.lua -- drives Neovim's own LSP client against Botlish's
-- language server (tests/lsp-neovim.test, LSP-MILESTONE-1.md, "Editors").
--
--   nvim --headless --clean --cmd "lua vim.g.botlish_lsp_cmd = {...}" \
--        -u editors/neovim/botlish.lua -c "luafile tests/lsp-neovim.lua" DIR/main.bot
--
-- DIR holds a two-module program (main.bot importing shapes.bot and
-- std::list, with one unbound name). Everything an editor user does goes
-- through the real client: attaching, diagnostics as Neovim shows them,
-- hover, go-to-definition into another file and into the standard library,
-- references, unsaved edits (the client's own didChange), a syntax error and
-- its fix, and an editing session through syntax errors
-- (SYNTAX-RECOVERY-MILESTONE-1.md): fresh answers around the malformed line,
-- the last complete analysis answering (stale) inside it, a syntax error in
-- the imported module (opened as a second buffer), and its repair. What
-- happened is written as JSON to $BOTLISH_NVIM_OUT, and Neovim quits; every
-- wait is bounded.

local out = {}
local function record(key, value) out[key] = value end
local function finish()
  local f = io.open(os.getenv('BOTLISH_NVIM_OUT'), 'w')
  f:write(vim.json.encode(out))
  f:close()
  vim.cmd('qa!')
end

local ok, err = pcall(function()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  record('filetype', vim.bo[buf].filetype)
  assert(vim.wait(30000, function() return #vim.lsp.get_clients({ bufnr = buf }) > 0 end), 'no client attached')
  local client = vim.lsp.get_clients({ bufnr = buf })[1]
  record('server', client.server_info and client.server_info.name or '')
  record('encoding', client.offset_encoding)

  local function diagnostics()
    return vim.tbl_map(function(d)
      return { line = d.lnum, col = d.col, code = d.code, message = d.message, source = d.source }
    end, vim.diagnostic.get(buf))
  end
  local function errors()
    return #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.ERROR })
  end
  local function request(method, params)
    local responses = vim.lsp.buf_request_sync(buf, method, params, 30000) or {}
    for _, r in pairs(responses) do return r.result end
  end
  local function at(line, col, extra)
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_win_set_cursor(win, { line + 1, col })
    local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
    for k, v in pairs(extra or {}) do params[k] = v end
    return params
  end
  local function hover(line, col)
    local result = request('textDocument/hover', at(line, col))
    return result and result.contents and result.contents.value or vim.NIL
  end
  -- Jumps to the definition at LINE, COL as the user's command does; the
  -- buffer and position it lands on.
  local function jump(line, col)
    at(line, col)
    local before = vim.api.nvim_get_current_buf()
    vim.lsp.buf.definition()
    vim.wait(30000, function() return vim.api.nvim_get_current_buf() ~= before end)
    local landed = { file = vim.fs.basename(vim.api.nvim_buf_get_name(0)), cursor = vim.api.nvim_win_get_cursor(0) }
    vim.api.nvim_win_set_buf(win, buf)
    return landed
  end

  -- The program as saved: one unbound name.
  assert(vim.wait(30000, function() return #vim.diagnostic.get(buf) > 0 end), 'no diagnostics')
  record('initial', diagnostics())
  record('hover', hover(3, 6))
  record('definition', jump(3, 6))
  record('std_definition', jump(4, 17))
  local area = request('textDocument/references', at(3, 12, { context = { includeDeclaration = true } }))
  record('references_area', vim.tbl_map(function(l) return vim.fs.basename(vim.uri_to_fname(l.uri)) .. ':' .. l.range.start.line end, area or {}))

  -- An unsaved fix: the client's didChange; the error goes (a warning of
  -- the program, hidden by the error, appears).
  vim.api.nvim_buf_set_lines(buf, 5, 6, false, { 'a + b' })
  record('fixed_waited', vim.wait(30000, function() return errors() == 0 end))
  record('fixed', diagnostics())

  -- A syntax error: reported; the analysis goes on around it. Hover on a
  -- declaration it cannot affect answers fresh from the current analysis;
  -- inside the malformed line, where it knows nothing, the last complete
  -- analysis answers, marked stale.
  vim.api.nvim_buf_set_lines(buf, 5, 6, false, { 'a + ' })
  record('syntax_waited', vim.wait(30000, function()
    local ds = vim.diagnostic.get(buf)
    return #ds > 0 and ds[1].code == 'SURFACE SYNTAX'
  end))
  record('syntax', diagnostics())
  record('syntax_hover', hover(3, 6))
  record('syntax_hover_b', hover(4, 0))
  record('stale_hover', hover(5, 0))

  -- Fixed again: fresh answers.
  vim.api.nvim_buf_set_lines(buf, 5, 6, false, { 'a + b' })
  record('recovered_waited', vim.wait(30000, function() return errors() == 0 end))
  record('recovered_hover', hover(3, 6))

  -- A syntax error in the imported module, in its own buffer: reported
  -- there; the importer's answers stay fresh, the malformed function's
  -- declared signature included; repaired, its diagnostic goes.
  local shapes = vim.fs.joinpath(vim.fs.dirname(vim.api.nvim_buf_get_name(buf)), 'shapes.bot')
  vim.cmd('edit ' .. vim.fn.fnameescape(shapes))
  local mbuf = vim.api.nvim_get_current_buf()
  vim.api.nvim_win_set_buf(win, buf)
  assert(vim.wait(30000, function() return #vim.lsp.get_clients({ bufnr = mbuf }) > 0 end), 'no client attached to the module')
  vim.api.nvim_buf_set_lines(mbuf, 1, 2, false, { '    w *' })
  record('module_waited', vim.wait(30000, function()
    local ds = vim.diagnostic.get(mbuf)
    return #ds > 0 and ds[1].code == 'SURFACE SYNTAX'
  end))
  local mds = vim.diagnostic.get(mbuf)
  record('module_syntax', mds[1] and (mds[1].lnum .. ':' .. mds[1].col .. ': ' .. mds[1].message) or vim.NIL)
  record('module_main_errors', errors())
  record('module_hover', hover(3, 6))
  record('module_hover_b', hover(4, 0))
  vim.api.nvim_buf_set_lines(mbuf, 1, 2, false, { '    w * h' })
  record('module_repaired', vim.wait(30000, function() return #vim.diagnostic.get(mbuf) == 0 end))
  record('module_repaired_hover', hover(3, 6))
  record('modified', vim.bo[buf].modified)
  record('module_modified', vim.bo[mbuf].modified)
end)
record('ok', ok)
record('error', ok and '' or tostring(err))
finish()
