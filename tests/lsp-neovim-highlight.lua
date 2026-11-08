-- lsp-neovim-highlight.lua -- Neovim's highlighting of Botlish
-- (tests/lsp-neovim.test, SYNTAX-HIGHLIGHTING-MILESTONE-1.md): the syntax
-- editors/neovim/botlish.lua puts on the runtime path, and the server's
-- semantic tokens as Neovim's own client receives them.
--
--   nvim --headless --clean --cmd "lua vim.g.botlish_lsp_cmd = {...}" \
--        -u editors/neovim/botlish.lua -c "luafile tests/lsp-neovim-highlight.lua" FILE
--
-- BOTLISH_NVIM_POSITIONS: a JSON list of {LINE, COLUMN} (0-based, bytes) whose
-- syntax item is recorded; BOTLISH_NVIM_TOKEN_AT: {LINE, COLUMN} whose
-- semantic token type is recorded once the server's tokens arrive ("" for
-- none asked). The record goes to $BOTLISH_NVIM_OUT as JSON, and Neovim
-- quits; every wait is bounded.

local out = {}
local ok, err = pcall(function()
  local buf = vim.api.nvim_get_current_buf()
  vim.cmd('syntax on')
  out.filetype = vim.bo[buf].filetype
  out.syntax = vim.b[buf].current_syntax or ''
  out.groups = {}
  for _, p in ipairs(vim.json.decode(os.getenv('BOTLISH_NVIM_POSITIONS'))) do
    table.insert(out.groups, vim.fn.synIDattr(vim.fn.synID(p[1] + 1, p[2] + 1, 1), 'name'))
  end
  out.token = ''
  local probe = os.getenv('BOTLISH_NVIM_TOKEN_AT')
  if probe and probe ~= '' then
    local at = vim.json.decode(probe)
    assert(vim.wait(30000, function() return #vim.lsp.get_clients({ bufnr = buf }) > 0 end), 'no client attached')
    vim.wait(60000, function()
      local tokens = vim.lsp.semantic_tokens.get_at_pos(buf, at[1], at[2]) or {}
      if #tokens > 0 then
        out.token = tokens[1].type
        return true
      end
      return false
    end, 100)
  end
end)
out.ok = ok
out.error = ok and '' or tostring(err)
local f = io.open(os.getenv('BOTLISH_NVIM_OUT'), 'w')
f:write(vim.json.encode(out))
f:close()
vim.cmd('qa!')
