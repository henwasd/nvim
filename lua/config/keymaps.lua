-- Native Keymaps
local map = vim.keymap.set

-- Desativa a acao padrao da barra de espaco no modo Normal e Visual para funcionar puramente como Leader
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Selecionar tudo
map({ "n", "v" }, "<C-a>", "ggVG", { desc = "Select all" })

-- Salvar rapido (sem formatar)
map({ "n", "i", "x" }, "<C-s>", "<cmd>noautocmd w<cr>", { desc = "Save File (No Format)" })

-- Area de transferencia do sistema (Clipboard)
map("v", "<C-c>", '"+y', { desc = "Copy to clipboard" })
map("v", "<C-v>", '"+p', { desc = "Paste from clipboard" })
map("i", "<C-v>", "<C-r>+", { desc = "Paste from clipboard" })

-- Redimensionar janelas com Alt + Setas
map({ "n", "i", "v", "t" }, "<A-Up>", "<cmd>resize +2<cr>", { desc = "Increase Height" })
map({ "n", "i", "v", "t" }, "<A-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Height" })
map({ "n", "i", "v", "t" }, "<A-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Width" })
map({ "n", "i", "v", "t" }, "<A-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Width" })

-- Navegacao entre janelas com Ctrl + hjkl
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })

-- Navegacao de buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })

-- Terminal Flutuante Nativo (Zero Plugins)
local terminal = require("config.terminal")
map({ "n", "t" }, "<C-/>", function() terminal.toggle({ cwd = vim.fn.getcwd() }) end, { desc = "Toggle Terminal (CWD)" })
map({ "n", "t" }, "<c-_>", function() terminal.toggle({ cwd = vim.fn.getcwd() }) end, { desc = "Toggle Terminal (CWD)" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

-- Explorador de arquivos (Oil.nvim)
map("n", "<leader>e", function()
  local ok, oil = pcall(require, "oil")
  if ok then oil.open() else vim.cmd("Ex") end
end, { desc = "Explorer (Oil)" })

-- Helpers para busca com Mini Pick e Mini Extra
local pick = function(fn_name)
  return function()
    local ok, p = pcall(require, "mini.pick")
    if ok and p.builtin[fn_name] then
      p.builtin[fn_name]()
    end
  end
end

local extra_pick = function(fn_name, opts)
  return function()
    local ok, extra = pcall(require, "mini.extra")
    if ok and extra.pickers and extra.pickers[fn_name] then
      extra.pickers[fn_name](opts or {})
    end
  end
end

-- Menu de Arquivos e Navegacao (<leader>f)
map("n", "<leader>ff", pick("files"), { desc = "Find Files" })
map("n", "<leader>fg", pick("grep_live"), { desc = "Live Grep" })
map("n", "<leader>fb", pick("buffers"), { desc = "Buffers" })
map("n", "<leader>ft", function() terminal.toggle({ cwd = vim.fn.getcwd() }) end, { desc = "Terminal (cwd)" })
map("n", "<leader>fh", pick("help"), { desc = "Help Tags" })

-- Menu Geral de Busca / Search (<leader>s)
map("n", "<leader>sd", extra_pick("diagnostic", { scope = "all" }), { desc = "Diagnostics (Workspace)" })
map("n", "<leader>sD", extra_pick("diagnostic", { scope = "current" }), { desc = "Diagnostics (Buffer)" })
map("n", "<leader>ss", extra_pick("lsp", { scope = "document_symbol" }), { desc = "Document Symbols" })
map("n", "<leader>sS", extra_pick("lsp", { scope = "workspace_symbol" }), { desc = "Workspace Symbols" })
map("n", "<leader>sc", extra_pick("commands"), { desc = "Commands" })
map("n", "<leader>sk", extra_pick("keymaps"), { desc = "Keymaps" })
map("n", "<leader>sh", extra_pick("history", { scope = ":" }), { desc = "Command History" })
map("n", "<leader>sm", extra_pick("marks"), { desc = "Marks" })
map("n", "<leader>sr", extra_pick("registers"), { desc = "Registers" })
map("n", "<leader>sl", extra_pick("buf_lines", { scope = "current" }), { desc = "Buffer Lines" })
map("n", "<leader>so", extra_pick("oldfiles"), { desc = "Oldfiles (Recent)" })
map("n", "<leader>st", extra_pick("treesitter"), { desc = "Treesitter Nodes" })
map("n", "<leader>sg", extra_pick("git_commits"), { desc = "Git Commits" })
map("n", "<leader>sw", function()
  local ok, p = pcall(require, "mini.pick")
  if ok and p.builtin.grep then
    p.builtin.grep({ pattern = vim.fn.expand("<cword>") })
  end
end, { desc = "Search Current Word" })

-- Menu de Codigo & LSP (<leader>c)
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename Symbol" })
map("n", "<leader>cf", function()
  -- Quando existe .vscode/settings.json, replica o "save" do time: organize
  -- imports + fixAll do Biome e so depois formata (sempre com o Biome, que e a
  -- fonte de verdade do biome.json). Sem .vscode, mantem o comportamento antigo.
  require("config.project").format({ notify = true })
end, { desc = "Format Document" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "<leader>cl", "<cmd>checkhealth vim.lsp<cr>", { desc = "LSP Info" })

-- Menu Git (<leader>g) com Gitsigns + Mini Extra + Terminal
local gs = function(action, ...)
  local args = { ... }
  return function()
    local ok, gitsigns = pcall(require, "gitsigns")
    if ok and gitsigns[action] then
      gitsigns[action](unpack(args))
    end
  end
end

map("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git Status (Fugitive)" })
map("n", "<leader>gb", gs("blame_line", { full = true }), { desc = "Git Blame Line" })
map("n", "<leader>gp", gs("preview_hunk"), { desc = "Preview Hunk" })
map("n", "<leader>gd", gs("diffthis"), { desc = "Diff Hunk" })
map("n", "<leader>gr", gs("reset_hunk"), { desc = "Reset Hunk" })
map("n", "<leader>gR", gs("reset_buffer"), { desc = "Reset Buffer" })
map("n", "<leader>ga", gs("stage_hunk"), { desc = "Stage Hunk" })
map("n", "<leader>gu", gs("undo_stage_hunk"), { desc = "Undo Stage Hunk" })
map("n", "<leader>gc", extra_pick("git_commits"), { desc = "Git Commits (Pick)" })
map("n", "<leader>gB", extra_pick("git_branches"), { desc = "Git Branches (Pick)" })
map("n", "<leader>gt", function()
  terminal.toggle({ cmd = "git log --oneline --graph --decorate -n 30" })
end, { desc = "Git Log (Terminal)" })

-- Navegação rápida entre hunks com [g e ]g
map("n", "]g", gs("next_hunk"), { desc = "Next Git Hunk" })
map("n", "[g", gs("prev_hunk"), { desc = "Previous Git Hunk" })

-- Navegacao LSP & Diagnosticos
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to Declaration" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go to References" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })

-- Limpar destaque de busca ao pressionar Esc no modo Normal
map("n", "<Esc>", "<cmd>nohlsearch<cr><Esc>", { desc = "Clear Search Highlights" })

-- Manter selecao ao indentar no modo visual
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Mover linhas selecionadas para cima ou baixo
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move Selection Down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move Selection Up" })

-- Comportamento ergonomico do Menu de Autocomplete Nativo e Supermaven (IA)
map("i", "<Tab>", function()
  local ok_sm, sm_preview = pcall(require, "supermaven-nvim.completion_preview")
  if ok_sm and sm_preview.has_suggestion() then
    sm_preview.on_accept_suggestion()
    return ""
  elseif vim.fn.pumvisible() == 1 then
    return "<C-n>"
  elseif vim.snippet and vim.snippet.active({ direction = 1 }) then
    vim.snippet.jump(1)
    return ""
  else
    return "<Tab>"
  end
end, { expr = true, silent = true, desc = "Accept AI Suggestion / Next Completion Item / Snippet Jump" })

map("i", "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-p>"
  elseif vim.snippet and vim.snippet.active({ direction = -1 }) then
    vim.snippet.jump(-1)
    return ""
  else
    return "<S-Tab>"
  end
end, { expr = true, silent = true, desc = "Previous Completion Item or Snippet Jump" })

map("i", "<CR>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-y>"
  else
    return "<CR>"
  end
end, { expr = true, silent = true, desc = "Accept Completion or Newline" })
