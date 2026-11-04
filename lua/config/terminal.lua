-- 100% Native Floating Multi-Terminal (Zero External Plugins)
-- Suporte a múltiplos terminais concorrentes, alternância rápida e seletor via mini.pick
local M = {}

local state = {
  terminals = {}, -- lista de { id = number, buf = bufnr, job_id = number, name = string, cwd = string, cmd = string, auto_close = boolean }
  current_idx = 1,
  win = -1,
}

-- Dimensões padronizadas da janela flutuante
local function get_dimensions()
  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.85)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)
  return width, height, col, row
end

-- Limpeza de terminal fechado
local function cleanup_term(buf)
  for i, term in ipairs(state.terminals) do
    if term.buf == buf then
      table.remove(state.terminals, i)
      if state.current_idx > #state.terminals then
        state.current_idx = math.max(1, #state.terminals)
      end

      -- Se a janela flutuante estiver aberta, atualiza ou fecha
      if vim.api.nvim_win_is_valid(state.win) then
        if #state.terminals > 0 then
          local cur = state.terminals[state.current_idx]
          if cur and vim.api.nvim_buf_is_valid(cur.buf) then
            vim.api.nvim_win_set_buf(state.win, cur.buf)
            M.update_title()
            vim.cmd.startinsert()
          end
        else
          vim.api.nvim_win_hide(state.win)
          state.win = -1
        end
      end
      break
    end
  end
end

-- Obtém terminal atual válido
local function get_current()
  if #state.terminals == 0 then
    return nil
  end
  if state.current_idx < 1 or state.current_idx > #state.terminals then
    state.current_idx = 1
  end
  local term = state.terminals[state.current_idx]
  if not term or not vim.api.nvim_buf_is_valid(term.buf) then
    if term then cleanup_term(term.buf) end
    return get_current()
  end
  return term
end

-- Atualiza título da janela flutuante
function M.update_title()
  if not vim.api.nvim_win_is_valid(state.win) then
    return
  end
  local term = get_current()
  if not term then
    return
  end

  local folder = vim.fs.basename(term.cwd)
  if folder == "" then folder = term.cwd end
  local title = string.format(" Terminal [%d/%d]: %s (%s) ", state.current_idx, #state.terminals, term.name, folder)

  vim.api.nvim_win_set_config(state.win, {
    title = title,
    title_pos = "center",
  })
end

-- Cria uma nova entrada de terminal
local function create_term(opts)
  opts = opts or {}
  local cwd = opts.cwd or vim.fn.getcwd()
  local cmd = opts.cmd or vim.o.shell

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].buflisted = false

  local default_name = opts.name or (opts.cmd and vim.fs.basename(opts.cmd) or "shell")
  local term_entry = {
    id = #state.terminals + 1,
    buf = buf,
    cwd = cwd,
    cmd = cmd,
    name = default_name,
    auto_close = opts.auto_close ~= false and not opts.cmd,
  }

  -- Listener para remoção quando o buffer for deletado
  vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
    buffer = buf,
    once = true,
    callback = function()
      vim.schedule(function()
        cleanup_term(buf)
      end)
    end,
  })

  -- Listener para quando o processo encerrar (ex: usuário digitou 'exit')
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = buf,
    once = true,
    callback = function()
      vim.schedule(function()
        if term_entry.auto_close and vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end)
    end,
  })

  table.insert(state.terminals, term_entry)
  state.current_idx = #state.terminals
  return term_entry
end

-- Exibe janela flutuante com o terminal desejado
local function show_window(term)
  if not term or not vim.api.nvim_buf_is_valid(term.buf) then
    return
  end

  local width, height, col, row = get_dimensions()
  local folder = vim.fs.basename(term.cwd)
  if folder == "" then folder = term.cwd end
  local title = string.format(" Terminal [%d/%d]: %s (%s) ", state.current_idx, #state.terminals, term.name, folder)

  if vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_set_buf(state.win, term.buf)
    vim.api.nvim_win_set_config(state.win, {
      title = title,
      title_pos = "center",
    })
  else
    state.win = vim.api.nvim_open_win(term.buf, true, {
      relative = "editor",
      width = width,
      height = height,
      col = col,
      row = row,
      style = "minimal",
      border = "rounded",
      title = title,
      title_pos = "center",
    })
  end

  -- Inicializa o processo do terminal se ainda não tiver iniciado
  if vim.bo[term.buf].buftype ~= "terminal" then
    vim.api.nvim_win_call(state.win, function()
      term.job_id = vim.fn.jobstart(term.cmd, {
        term = true,
        cwd = term.cwd,
      })
    end)
  end

  vim.cmd.startinsert()
end

-- Alterna visibilidade do terminal (Toggle)
function M.toggle(opts)
  if vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_hide(state.win)
    state.win = -1
    return
  end

  local cur = get_current()
  if not cur or (opts and opts.cmd) then
    cur = create_term(opts)
  end

  show_window(cur)
end

-- Cria explicitamente um novo terminal
function M.new(opts)
  local term = create_term(opts)
  show_window(term)
  vim.notify(
    string.format("Novo terminal [%d/%d] criado: %s", state.current_idx, #state.terminals, term.name),
    vim.log.levels.INFO,
    { title = "Terminal" }
  )
end

-- Alterna para o próximo terminal (circular)
function M.next()
  if #state.terminals <= 1 then
    vim.notify("Apenas 1 terminal ativo.", vim.log.levels.WARN, { title = "Terminal" })
    return
  end
  state.current_idx = (state.current_idx % #state.terminals) + 1
  local term = get_current()
  if term then
    show_window(term)
  end
end

-- Alterna para o terminal anterior (circular)
function M.prev()
  if #state.terminals <= 1 then
    vim.notify("Apenas 1 terminal ativo.", vim.log.levels.WARN, { title = "Terminal" })
    return
  end
  state.current_idx = (state.current_idx - 2 + #state.terminals) % #state.terminals + 1
  local term = get_current()
  if term then
    show_window(term)
  end
end

-- Pula para um índice específico
function M.goto_idx(idx)
  if idx < 1 or idx > #state.terminals then
    return
  end
  state.current_idx = idx
  local term = get_current()
  if term then
    show_window(term)
  end
end

-- Menu seletor interativo (usa mini.pick via vim.ui.select)
function M.select()
  if #state.terminals == 0 then
    vim.notify("Nenhum terminal ativo. Use <leader>tn para criar um.", vim.log.levels.INFO, { title = "Terminal" })
    return
  end

  local items = {}
  for i, t in ipairs(state.terminals) do
    local is_cur = (i == state.current_idx) and " (ativo)" or ""
    table.insert(items, {
      idx = i,
      label = string.format("[%d] %s — %s%s", i, t.name, t.cwd, is_cur),
    })
  end

  vim.ui.select(items, {
    prompt = "Selecionar Terminal: ",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if choice and choice.idx then
      M.goto_idx(choice.idx)
    end
  end)
end

-- Renomeia o terminal ativo
function M.rename()
  local term = get_current()
  if not term then
    vim.notify("Nenhum terminal ativo para renomear.", vim.log.levels.WARN, { title = "Terminal" })
    return
  end

  vim.ui.input({
    prompt = string.format("Novo nome para o terminal [%d]: ", state.current_idx),
    default = term.name,
  }, function(input)
    if input and input:match("%S") then
      term.name = input:gsub("^%s*(.-)%s*$", "%1")
      M.update_title()
      vim.notify("Terminal renomeado para: " .. term.name, vim.log.levels.INFO, { title = "Terminal" })
    end
  end)
end

-- Encerra o terminal atual ou especificado
function M.kill(idx)
  idx = idx or state.current_idx
  local term = state.terminals[idx]
  if not term then
    vim.notify("Nenhum terminal ativo para fechar.", vim.log.levels.WARN, { title = "Terminal" })
    return
  end

  local buf = term.buf
  cleanup_term(buf)

  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
  vim.notify("Terminal encerrado.", vim.log.levels.INFO, { title = "Terminal" })
end

-- Retorna a lista de terminais (para inspeção ou statusline)
function M.get_terminals()
  return state.terminals, state.current_idx
end

-- Redimensionamento dinâmico automático ao redimensionar a janela do Neovim
vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("NativeTerminalAutoResize", { clear = true }),
  callback = function()
    if vim.api.nvim_win_is_valid(state.win) then
      local width, height, col, row = get_dimensions()
      vim.api.nvim_win_set_config(state.win, {
        width = width,
        height = height,
        col = col,
        row = row,
      })
    end
  end,
})

return M
