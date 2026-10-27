-- Integracao com as configuracoes de projeto do VS Code (.vscode/settings.json).
--
-- Le apenas o que tem equivalente real no Neovim:
--   * editor.tabSize / editor.insertSpaces  -> tabstop, shiftwidth, expandtab
--   * editor.formatOnSave                   -> opt-in por projeto (:ProjectAutoformat)
--   * editor.defaultFormatter               -> so atua quando o formatador e o Biome
--   * editor.codeActionsOnSave              -> source.fixAll.biome / source.organizeImports.biome
--
-- Chaves `js/ts.*` pertencem a extensao TypeScript do VS Code e nao existem no
-- `tsc --lsp`; `workbench.*`, `quickSuggestions` e os formatadores internos de
-- JSON/HTML tambem nao tem equivalente. O `biome.json` continua sendo a fonte
-- de verdade da formatacao.
--
-- O arquivo do VS Code e JSONC (comentarios + virgula final), por isso o parse
-- passa por um sanitizador antes de chegar no vim.json.decode.
local M = {}

local uv = vim.uv or vim.loop

-- Cache por caminho. "stamp" junta mtime + tamanho para detectar edicoes feitas
-- pelo time no VS Code sem reler o arquivo a cada buffer.
local cache = {}
local warned = {}

-- Nomes de linguagem do VS Code que diferem do filetype do Neovim.
local filetype_alias = {
  sh = "shellscript",
  zsh = "shellscript",
}

-- Campos podem estar no escopo global ou em blocos por linguagem: "[typescriptreact]".
local function scoped(settings, filetype, key)
  if type(settings) ~= "table" then
    return nil
  end

  local lang = filetype_alias[filetype] or filetype
  local block = settings["[" .. lang .. "]"]
  if type(block) == "table" and block[key] ~= nil then
    return block[key]
  end

  return settings[key]
end

local function skip_blank_and_comments(text, index, last)
  while index <= last do
    local char = text:sub(index, index)
    if char:match("%s") then
      index = index + 1
    elseif char == "/" and text:sub(index + 1, index + 1) == "/" then
      index = text:find("\n", index + 2, true) or (last + 1)
    elseif char == "/" and text:sub(index + 1, index + 1) == "*" then
      local close = text:find("*/", index + 2, true)
      index = close and (close + 2) or (last + 1)
    else
      break
    end
  end
  return index
end

-- Converte JSONC em JSON: remove comentarios e virgulas finais sem tocar no
-- conteudo de strings (inclusive strings com ",}" ou "//").
local function sanitize_jsonc(text)
  local out = {}
  local index, last = 1, #text
  local in_string, escaped = false, false

  while index <= last do
    local char = text:sub(index, index)

    if in_string then
      out[#out + 1] = char
      if escaped then
        escaped = false
      elseif char == "\\" then
        escaped = true
      elseif char == '"' then
        in_string = false
      end
      index = index + 1
    elseif char == '"' then
      in_string = true
      out[#out + 1] = char
      index = index + 1
    elseif char == "/" and text:sub(index + 1, index + 1) == "/" then
      index = text:find("\n", index + 2, true) or (last + 1)
    elseif char == "/" and text:sub(index + 1, index + 1) == "*" then
      local close = text:find("*/", index + 2, true)
      index = close and (close + 2) or (last + 1)
    elseif char == "," then
      local next_index = skip_blank_and_comments(text, index + 1, last)
      local next_char = text:sub(next_index, next_index)
      if next_char ~= "}" and next_char ~= "]" then
        out[#out + 1] = char
      end
      index = index + 1
    else
      out[#out + 1] = char
      index = index + 1
    end
  end

  return table.concat(out)
end

local function read_settings(path)
  local stat = uv.fs_stat(path)
  if not stat then
    cache[path] = nil
    return nil
  end

  local stamp = ("%d:%d"):format(stat.mtime.sec, stat.size)
  local cached = cache[path]
  if cached and cached.stamp == stamp then
    return cached.data
  end

  local ok_read, lines = pcall(vim.fn.readfile, path)
  if not ok_read or type(lines) ~= "table" then
    return nil
  end

  local ok_decode, data = pcall(vim.json.decode, sanitize_jsonc(table.concat(lines, "\n")))
  if not ok_decode or type(data) ~= "table" then
    if not warned[path] then
      warned[path] = true
      vim.notify(
        ("Nao foi possivel interpretar %s como JSONC."):format(path),
        vim.log.levels.WARN,
        { title = "Project" }
      )
    end
    return nil
  end

  cache[path] = { stamp = stamp, data = data }
  return data
end

local function search_start(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name ~= "" and vim.fn.filereadable(name) == 1 then
    return vim.fs.dirname(name)
  end
  return vim.fn.getcwd()
end

-- Sobe a partir do buffer ate o .vscode/settings.json mais proximo. O projeto
-- pode estar aninhado (ex.: repo RemotaSafe > Application/...UI), entao o cwd
-- nao serve como referencia.
local function find_settings(bufnr)
  local dir = search_start(bufnr)
  while dir do
    local path = vim.fs.joinpath(dir, ".vscode", "settings.json")
    if uv.fs_stat(path) then
      return path, dir
    end

    local parent = vim.fs.dirname(dir)
    if parent == dir then
      break
    end
    dir = parent
  end

  return nil, nil
end

local function project_context(bufnr)
  local path, root = find_settings(bufnr)
  if not path then
    return nil
  end

  local data = read_settings(path)
  if not data then
    return nil
  end

  return { path = path, root = root, data = data }
end

local function apply_indent(bufnr, settings)
  local filetype = vim.bo[bufnr].filetype

  local tab_size = scoped(settings, filetype, "editor.tabSize")
  if type(tab_size) == "number" and tab_size > 0 then
    vim.bo[bufnr].tabstop = tab_size
    vim.bo[bufnr].shiftwidth = tab_size
  end

  local insert_spaces = scoped(settings, filetype, "editor.insertSpaces")
  if type(insert_spaces) == "boolean" then
    vim.bo[bufnr].expandtab = insert_spaces
  end
end

local BIOME_FORMATTER = "biomejs.biome"

local function default_formatter(settings, filetype)
  local value = scoped(settings, filetype, "editor.defaultFormatter")
  if type(value) == "string" and value ~= "" then
    return value
  end
  return nil
end

-- Acoes do Biome que existem no editor. As acoes `*.ts` do VS Code
-- (addMissingImports, organizeImports) sao do servidor TypeScript da extensao.
local function biome_action_kinds(settings, filetype)
  local actions = scoped(settings, filetype, "editor.codeActionsOnSave")
  if type(actions) ~= "table" then
    return {}
  end

  local kinds = {}
  -- Organizar imports antes do fixAll evita que o fixAll remova imports que
  -- seriam apenas reordenados.
  for _, kind in ipairs({ "source.organizeImports.biome", "source.fixAll.biome" }) do
    local value = actions[kind]
    if value == "explicit" or value == "always" then
      kinds[#kinds + 1] = kind
    end
  end

  return kinds
end

local function biome_client(bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "biome" })) do
    return client
  end
  return nil
end

-- O Biome resolve as code actions sob demanda (codeAction/resolve), como o
-- Neovim faz em vim.lsp.buf.code_action.
local function resolve_action(client, action, bufnr)
  if (action.edit and action.command) or not client:supports_method("codeAction/resolve") then
    return action
  end

  local resolved = client:request_sync("codeAction/resolve", action, 1000, bufnr)
  if resolved and resolved.result then
    return resolved.result
  end

  return action
end

local function apply_code_actions(bufnr, client, kinds)
  if #kinds == 0 or not client:supports_method("textDocument/codeAction") then
    return
  end

  -- make_range_params usa a janela para calcular a posicao do cursor.
  local window = vim.fn.bufwinid(bufnr)
  local ok_params, params = pcall(vim.lsp.util.make_range_params, window == -1 and 0 or window, client.offset_encoding)
  if not ok_params then
    return
  end

  params.context = { only = kinds, diagnostics = {}, triggerKind = 1 }

  local response = client:request_sync("textDocument/codeAction", params, 1000, bufnr)
  if not response or response.err or not response.result then
    return
  end

  for _, action in ipairs(response.result) do
    local final = resolve_action(client, action, bufnr)

    if final.edit then
      vim.lsp.util.apply_workspace_edit(final.edit, client.offset_encoding)
    end

    if final.command then
      pcall(function()
        client:exec_cmd(final.command, { bufnr = bufnr })
      end)
    end
  end
end

-- O Biome registra formatacao e code actions dinamicamente logo apos o
-- initialize (tipicamente dezenas de ms). No primeiro arquivo da sessao vale
-- esperar um pouco em vez de perder a formatacao.
local function wait_ready(client, needs_code_action)
  local function ready()
    if not client:supports_method("textDocument/formatting") then
      return false
    end
    return not needs_code_action or client:supports_method("textDocument/codeAction")
  end

  if ready() then
    return true
  end
  return vim.wait(1000, ready, 20)
end

local function format_with(client, bufnr, timeout_ms)
  if not client:supports_method("textDocument/formatting") then
    return false
  end

  return pcall(vim.lsp.buf.format, {
    bufnr = bufnr,
    async = false,
    timeout_ms = timeout_ms or 2000,
    filter = function(other)
      return other.id == client.id
    end,
  })
end

--- Contexto do projeto para o buffer (settings.json, raiz e dados em cache).
function M.context(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local ctx = project_context(bufnr)
  if ctx then
    vim.b[bufnr].project = ctx
  end
  return ctx
end

--- `editor.formatOnSave` do projeto, considerando o formatador resolvido.
function M.project_format_on_save(bufnr)
  local ctx = vim.b[bufnr].project or project_context(bufnr)
  if not ctx then
    return false
  end

  local filetype = vim.bo[bufnr].filetype
  if scoped(ctx.data, filetype, "editor.formatOnSave") ~= true then
    return false
  end

  return default_formatter(ctx.data, filetype) == BIOME_FORMATTER
end

--- Precedencia: override da sessao > vim.g.autoformat > desligado.
function M.should_autoformat(bufnr)
  local override = M.autoformat_override
  if override == true then
    return true
  elseif override == false then
    return false
  elseif override == "project" then
    return M.project_format_on_save(bufnr)
  end

  if vim.g.autoformat == true then
    return true
  elseif vim.g.autoformat == "project" then
    return M.project_format_on_save(bufnr)
  end

  return false
end

--- Aplica o "save do VS Code": organizeImports.biome -> fixAll.biome -> format.
--- Fora de um projeto com .vscode, cai no comportamento anterior ao <leader>cf.
function M.format(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local timeout_ms = opts.timeout_ms or 2000

  local ctx = vim.b[bufnr].project or project_context(bufnr)
  if ctx then
    vim.b[bufnr].project = ctx
  end

  local client = biome_client(bufnr)

  if ctx then
    local filetype = vim.bo[bufnr].filetype
    local formatter = default_formatter(ctx.data, filetype)

    if formatter and formatter ~= BIOME_FORMATTER then
      if opts.notify then
        vim.notify(
          ("O VS Code usa '%s' para '%s', que nao tem equivalente no Neovim por projeto."):format(formatter, filetype),
          vim.log.levels.WARN,
          { title = "Project" }
        )
      end
      return false
    end

    if not client then
      if opts.notify then
        vim.notify("Biome nao esta conectado neste buffer.", vim.log.levels.WARN, { title = "Project" })
      end
      return false
    end

    local kinds = biome_action_kinds(ctx.data, filetype)
    wait_ready(client, #kinds > 0)
    apply_code_actions(bufnr, client, kinds)

    local ok = format_with(client, bufnr, timeout_ms)
    if not ok and opts.notify then
      vim.notify("Falha ao formatar com o Biome.", vim.log.levels.WARN, { title = "Project" })
    end
    return ok
  end

  -- Sem .vscode/settings.json: mantem o comportamento antigo.
  if client then
    wait_ready(client)
    return format_with(client, bufnr, timeout_ms)
  end

  if #vim.lsp.get_clients({ bufnr = bufnr }) == 0 then
    if opts.notify then
      vim.notify("Nenhum formatador LSP conectado neste buffer.", vim.log.levels.WARN, { title = "Project" })
    end
    return false
  end

  return pcall(vim.lsp.buf.format, { bufnr = bufnr, async = false, timeout_ms = timeout_ms })
end

function M.info()
  local bufnr = vim.api.nvim_get_current_buf()
  local ctx = M.context(bufnr)

  if not ctx then
    vim.notify(
      "Nenhum .vscode/settings.json encontrado acima deste buffer.",
      vim.log.levels.INFO,
      { title = "Project" }
    )
    return
  end

  local filetype = vim.bo[bufnr].filetype
  local kinds = biome_action_kinds(ctx.data, filetype)
  local lines = {
    "root: " .. ctx.root,
    "settings: " .. ctx.path,
    "filetype: " .. (filetype ~= "" and filetype or "?"),
    "defaultFormatter: " .. tostring(default_formatter(ctx.data, filetype)),
    "formatOnSave: " .. tostring(scoped(ctx.data, filetype, "editor.formatOnSave")),
    "codeActionsOnSave (Biome): " .. (#kinds > 0 and table.concat(kinds, ", ") or "nenhuma"),
    "tabstop/shiftwidth: " .. tostring(vim.bo[bufnr].tabstop) .. "/" .. tostring(vim.bo[bufnr].shiftwidth),
    "expandtab: " .. tostring(vim.bo[bufnr].expandtab),
    "autoformat global: " .. tostring(vim.g.autoformat),
    "autoformat sessao: " .. tostring(M.autoformat_override),
    "autoformat efetivo: " .. tostring(M.should_autoformat(bufnr)),
  }

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Project" })
end

function M.setup()
  local group = vim.api.nvim_create_augroup("ProjectVSCode", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(args)
      local ctx = project_context(args.buf)
      vim.b[args.buf].project = ctx
      if ctx then
        apply_indent(args.buf, ctx.data)
      end
    end,
  })

  -- Descarta o contexto em cache para reler o mtime no proximo uso.
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function(args)
      vim.b[args.buf].project = nil
    end,
  })

  vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    callback = function(args)
      if vim.bo[args.buf].buftype ~= "" then
        return
      end
      if not M.should_autoformat(args.buf) then
        return
      end
      M.format({ bufnr = args.buf, notify = false })
    end,
  })

  vim.api.nvim_create_user_command("ProjectInfo", M.info, {
    desc = "Mostra as configuracoes do .vscode aplicadas ao buffer",
  })

  vim.api.nvim_create_user_command("ProjectReload", function()
    cache = {}
    warned = {}
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) then
        vim.b[bufnr].project = nil
      end
    end
    vim.notify("Cache do .vscode/settings.json limpo.", vim.log.levels.INFO, { title = "Project" })
  end, { desc = "Recarrega .vscode/settings.json" })

  vim.api.nvim_create_user_command("ProjectAutoformat", function(opts)
    local value = opts.args
    if value == "" or value == "status" then
      vim.notify(
        ("autoformat global=%s | sessao=%s | projeto=%s"):format(
          tostring(vim.g.autoformat),
          tostring(M.autoformat_override),
          tostring(M.project_format_on_save(vim.api.nvim_get_current_buf()))
        ),
        vim.log.levels.INFO,
        { title = "Project" }
      )
      return
    end

    if value == "on" then
      M.autoformat_override = true
    elseif value == "off" then
      M.autoformat_override = false
    elseif value == "project" then
      M.autoformat_override = "project"
    else
      vim.notify("Uso: :ProjectAutoformat [on|off|project|status]", vim.log.levels.ERROR, { title = "Project" })
      return
    end

    vim.notify(("Autoformat desta sessao: %s"):format(value), vim.log.levels.INFO, { title = "Project" })
  end, {
    nargs = "?",
    complete = function()
      return { "on", "off", "project", "status" }
    end,
    desc = "Liga/desliga a formatacao ao salvar seguindo o .vscode",
  })
end

return M
