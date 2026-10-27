-- ====================================================================
--   Configuração Nativa do Neovim (v0.12+)
--   Máxima performance, zero overhead, arquitetura nativa com vim.pack
-- ====================================================================

-- 0. Define o Leader como Espaço antes de QUALQUER plugin ou atalho
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 1. Opções globais e tema Retrobox nativo com transparência
require("config.options")

-- 2. Plugins essenciais via API nativa vim.pack
require("plugins").setup()

-- 3. Statusline 100% nativa em Lua
require("config.statusline").setup()

-- 4. LSP Nativo, Autocomplete Nativo e Diagnósticos
require("lsp").setup()

-- 5. Integração com .vscode/settings.json (indentação, formatOnSave, Biome)
require("config.project").setup()

-- 6. Autocomandos nativos (sincronização de arquivos, highlight yank, etc.)
require("config.autocmds")

-- 7. Atalhos de teclado personalizados
require("config.keymaps")
