# 🧠 Contexto de Arquitetura e Decisões (Para Antigravity / IA)

Este documento registra detalhadamente **o que foi feito, por que foi feito e como manter** a configuração do Neovim neste repositório. Use este arquivo como guia principal ao configurar ou ajustar este ambiente em outros computadores (ex: notebook de trabalho).

---

## 🎯 1. Motivação da Migração (LazyVim ➡️ Nativo)

* **Problema Original**: O usuário utilizava o framework LazyVim. Embora conveniente, ele carregava dezenas de módulos em cascata, gerando alto consumo de memória, inicialização mais lenta e pequeno input lag em máquinas com processadores mais fracos (como notebooks corporativos ou de baixo consumo).
* **Objetivo**: Eliminar completamente o LazyVim e o `lazy.nvim`, substituindo o máximo possível por **recursos nativos do Neovim (v0.12+)** e plugins minimalistas, mantendo rigorosamente todas as funcionalidades, atalhos e ergonomia que o usuário já utilizava, alcançando a **máxima performance possível**.

---

## ⚙️ 2. De-Para das Substituições (O que mudou e por quê)

| Recurso | Antes (LazyVim) | Agora (Nativo / Minimalista) | Motivo / Implementação |
| :--- | :--- | :--- | :--- |
| **Gerenciador de Pacotes** | `lazy.nvim` | **`vim.pack`** (Nativo Neovim 0.12) | A API nativa `vim.pack` (`lua/plugins.lua`) clona via blobless clone (`--filter=blob:none`), gerencia o runtimepath sem nenhum wrapper e fornece comandos `:PackUpdate` e `:PackStatus`. |
| **Autocomplete de Código** | `blink.cmp` + snippets | **`vim.lsp.completion`** + **`vim.snippet`** | Zero processos extras em segundo plano. Usa a engine nativa do Neovim 0.12. Atalhos configurados em `lua/config/keymaps.lua`: `<Tab>` e `<S-Tab>` navegam ou pulam placeholders; `<CR>` aceita a sugestão. |
| **Tema de Cores** | Plugin `gruvbox.nvim` | **`retrobox`** nativo | O `retrobox` é a recriação oficial do Gruvbox embutida no binário C do Neovim. Transparência feita via `nvim_set_hl` nativo em `lua/config/options.lua`. Zero I/O de disco. |
| **Statusline** | Plugin `lualine.nvim` | **Statusline em Lua puro** | Implementada em `lua/config/statusline.lua`. Renderiza em <0.05ms com modo colorido, branch Git (lida diretamente do `.git/HEAD`), diagnósticos de erro/aviso e posição do cursor. |
| **Terminal Integrado** | Plugin `snacks.terminal` | **Terminal Flutuante Nativo** | Implementado em `lua/config/terminal.lua` usando `nvim_open_win` e `jobstart`. Abre instantaneamente centralizado no diretório atual de trabalho (`cwd`). Alterna com `<C-/>`, `<c-_>` e `<leader>ft`. |
| **Diagnósticos** | Plugin `tiny-inline-diagnostic` | **`vim.diagnostic.config`** nativo | Exibe virtual text com `●`, ícones na gutter lateral e janela flutuante detalhada em `<leader>cd`. |
| **LSP** | Modelo legado de `lspconfig` | **`vim.lsp.config`** nativo | Neovim 0.11+ descontinuou o framework `require('lspconfig')`. Usamos a API nativa `vim.lsp.config('server', { ... })` e `vim.lsp.enable('server')` em `lua/lsp/init.lua`. |
| **Servidores LSP (Web/TS)** | `ts_ls` genérico | **`tsc` nativo + `ts_ls` + `biome`** | O TypeScript 7 não fornece `tsserver.js`, então o `ts_ls` clássico quebra. Passamos a usar o **`tsc` nativo** (LSP embutido, TS >= 7) e o **Biome** como formatter/linter do projeto, com o `ts_ls` reservado para workspaces TS < 7. Detalhes na seção 5. |
| **Treesitter** | `nvim-treesitter` (branch `master`) | **`nvim-treesitter` (branch `main`)** | A branch `main` não tem mais `nvim-treesitter.configs`: o highlight é iniciado por buffer (`vim.treesitter.start`) e os parsers são compilados com o CLI `tree-sitter`. Detalhes na seção 5. |
| **Explorador de Arquivos** | `neo-tree` (desativado) / `oil` | **`oil.nvim`** | Permite editar diretórios como um buffer comum do Neovim (`dd` para apagar, editar texto para renomear, `:w` para salvar). Mapeado para `<leader>e`. |
| **Busca de Arquivos e Texto** | `snacks.picker` / `telescope` | **`mini.pick`** + `rg` + `fd` | Picker flutuante ultraleve (~1 arquivo Lua) integrado com `ripgrep` (`<leader>fg`) e `fd` (`<leader>ff`). Sem duplicatas redundantes no menu. |
| **Surround** | `mini.surround` | **`mini.surround`** | Mantido com os mesmos atalhos customizados: `gza` (adicionar), `gzd` (deletar), `gzr` (substituir). |
| **Múltiplos Cursores** | `vim-visual-multi` | **`vim-visual-multi`** | Mantido via `vim.pack` (`Ctrl+N` para multi-cursor). |
| **Which-Key** | `which-key.nvim` | **`which-key.nvim`** | Registrado via `vim.pack` com os menus limpos `f` (find), `b` (buffer), `c` (code), `e` (explorer), `a` (ai supermaven). |
| **Assistente IA** | Nenhum / Copilot | **`supermaven-nvim`** | IA de autocompletion de latência ultrabaixa integrada via `vim.pack`. Priorizado no `<Tab>` inteligente em `lua/config/keymaps.lua` com fallback para autocomplete nativo e snippets. Atalhos: `<C-j>` (aceita palavra), `<C-]>` (dispensa), `<leader>a` (menu). |
| **Renderização de Cores** | `mini.hipatterns` | **`catgoose/nvim-colorizer.lua`** | Pure Lua, zero overhead, processamento incremental restrito às linhas visíveis. Suporta `#hex` (3, 4, 6, 8 dígitos), `rgb()`, `rgba()`, `hsl()`, `hsla()`, `oklch()`, variáveis CSS `var(--...)`, nomes de cores CSS e classes Tailwind. Atalho `<leader>cc` para alternar. |

---

## 🛠️ 3. Guia de Manutenção e Regras para o Notebook de Trabalho

Quando estiver operando no notebook de trabalho:

### 1. Pré-requisitos do Sistema
* **Neovim >= 0.12**: Essencial para ter suporte a `vim.pack`, `vim.lsp.config` e `vim.lsp.completion`. Instale via `winget install Neovim.Neovim` (Windows) ou pacote oficial/appimage (Linux).
* **Ripgrep & FD**: Necessários para as buscas do `mini.pick`. No Windows: `winget install BurntSushi.ripgrep.MSVC` e `winget install sharkdp.fd`.

### 2. Regras de Código (Não viole!)
* **NÃO reinstale o LazyVim nem o `lazy.nvim`**. A arquitetura agora é nativa.
* **NÃO reative o auto-format global**. O usuário optou por `vim.g.autoformat = false` para não travar o fluxo de escrita. Formatação manual sempre por `<leader>cf` (`vim.lsp.buf.format`).
* **NÃO instale plugins visuais que usem timers pesados** (ex: `noice.nvim`, `mini.animate`, decorações de cursor excessivas).
* **Ao adicionar novos plugins**:
  1. Adicione a URL completa na tabela `M.specs` em `lua/plugins.lua`.
  2. Configure o plugin no mesmo arquivo usando `pcall(require, "nome")`.
  3. No Neovim, o `vim.pack.add` fará o clone automaticamente ao abrir o editor.
* **Ao configurar servidores de linguagens (LSP)**:
  - Adicione a configuração em `lua/lsp/init.lua` usando:
    ```lua
    vim.lsp.config("nome_do_server", { ... })
    vim.lsp.enable("nome_do_server")
    ```
  - **Atenção especial ao Windows**: Se o servidor rodar via Node.js (ex: `ts_ls`, `eslint`, `tailwindcss`), verifique se o comando precisa de `.cmd` no Windows (consulte a lógica de `ts_ls` existente em `lua/lsp/init.lua` como referência).

---

## 📂 4. Mapa Mental da Estrutura de Arquivos

```text
lua/
├── plugins.lua          -- Lista de repositórios git e setup do vim.pack
├── lsp/
│   └── init.lua         -- Configuração nativa de LSPs, autocomplete e diagnósticos
└── config/
    ├── options.lua      -- Opções nativas do Vim, wildmenu e tema retrobox com transparência
    ├── keymaps.lua      -- Todos os atalhos organizados (Ctrl+S, Ctrl+A, Alt+Setas, Terminal, MiniPick, Oil)
    ├── autocmds.lua     -- Autoreload de arquivos externos, highlight ao copiar (yank)
    ├── statusline.lua   -- Statusline 100% nativa em Lua (zero plugins)
    ├── terminal.lua     -- Terminal flutuante nativo centralizado
    └── project.lua      -- Integração com .vscode/settings.json (indentação, formatOnSave, Biome)
```

---

## 🧠 5. LSP, Formatação e Treesitter (decisões)

### 5.1 Por que o `ts_ls` foi substituído

O **TypeScript 7** (usado nos projetos RemotaSafe) não shipa mais `tsserver.js`. Ao abrir um arquivo, o `typescript-language-server` falhava com:

```
The TypeScript of the workspace (TypeScript 7.0.2 at "...\node_modules\typescript\lib")
provides no tsserver.js. No other valid TypeScript installation was found. Exiting.
```

Além disso, o binário nativo do TS 7 (`tsc --lsp`) tinha um *panic* em completion quando recebia `triggerCharacter = "]"`. A solução adotada:

| Servidor | Condição de ativação | Implementação (seção `lua/lsp/init.lua`) |
| :--- | :--- | :--- |
| **`tsc`** | Qualquer workspace com **TS >= 7** (`tsc`/`tsgo` no projeto ou PATH que aceite `--lsp`) | `vim.lsp.enable("tsc")` usando a config padrão do nvim-lspconfig (ela mesma detecta o binário e não atacha se não suportar `--lsp`). |
| **`ts_ls`** | Workspaces com **TS < 7** ou projetos **JS/Node.js** sem TS local | `root_dir` customizado: prioriza `tsconfig.json`/`jsconfig.json`/`package.json` mais próximo (suporta subpastas em monorepos como `/backend` e `/desktop-app`) e só bloqueia quando `major >= 7`. |
| **`rust_analyzer`** | Projetos **Rust / Tauri** (`Cargo.toml`) | `vim.lsp.config("rust_analyzer", ...)` com `allFeatures = true`, `clippy` no `checkOnSave` e `procMacro = { enable = true }` (suporte às macros do Tauri v2). |
| **`biome`** | Projetos com `biome.json` (o config do lspconfig acha o arquivo) | `cmd` customizado que resolve `node_modules/.bin/biome[.cmd/.exe]` do projeto antes de tentar o PATH global (o Biome raramente é global). |
| **`lua_ls`** | Apenas se `lua-language-server` estiver no PATH | Bloco opcional existente (hoje **não instalado** na máquina). |

*   **`<leader>cf`** (formatação) foi ajustado em `lua/config/keymaps.lua` para **filtrar o Biome** quando ele está atachado, evitando formatar duas vezes (Biome + tsc).
*   Nunca há dois servidores de TypeScript ativos no mesmo buffer: TS 7 usa `tsc`, TS < 7 usa `ts_ls`.

### 5.2 Treesitter (branch `main`)

O `nvim-treesitter` instalado pelo `vim.pack` é a branch **`main`**, que **removeu** o módulo `nvim-treesitter.configs` usado pela config antiga (`highlight = { enable = true }` simplesmente não fazia nada). Também não havia **nenhum parser** instalado.

Como está agora (`lua/plugins.lua`):

```lua
local ts = require('nvim-treesitter')
ts.install({ 'tsx', 'typescript', 'lua', 'vim', ... })  -- no-op quando já instalado

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    if not pcall(vim.treesitter.start, args.buf) then return end
    -- indent só para linguagens com queries/indents.scm
    ...
  end,
})
```

| Item | Valor |
| :--- | :--- |
| Parsers instalados em | `stdpath('data')/site/parser` → Windows `%LOCALAPPDATA%\nvim-data\site\parser` |
| Requisito | CLI **`tree-sitter`** no PATH (`npm install -g tree-sitter-cli`) |
| Requisito | Compilador C (`gcc`/`clang`/`cl`) — nesta máquina: `gcc` (WinLibs) |
| Adicionar linguagem | incluir na lista de `lua/plugins.lua` e reabrir o Neovim |

**Atenção (gotchas já vividos nesta máquina):**

1. `npm config get ignore-scripts` é `true`, então o `tree-sitter-cli` **não baixa o binário** no `npm install -g`. Rode:
   `node "$(npm root -g)/tree-sitter-cli/install.js"`
2. Erros de `tree-sitter build` do tipo *"Lock file ... appears stale"*: apague `%LOCALAPPDATA%\tree-sitter\lock\*.lock`.
* Testes headless que abrem arquivos com LSP ativo podem deixar o `PowerShell` esperando o pipe fechar — não é a config travada; confira com `Get-Process nvim`.

## 🔗 6. Integração com `.vscode/settings.json` (projetos do time)

O time do RemotaSafe usa VS Code; esta config lê o `.vscode/settings.json` do projeto **em runtime** para reduzir divergência sem exigir que ninguém instale nada. Implementado em `lua/config/project.lua` (chamado em `init.lua` como `config.project.setup()`).

A raiz é detectada subindo do buffer até o `.vscode/settings.json` mais próximo (o repo RemotaSafe é aninhado: `RemotaSafe > Application > Remota.Safe.Application.UI`), e o arquivo é lido como **JSONC** (comentários + vírgula final), com cache por `mtime` + tamanho.

### 6.1 O que é lido (e o que não é)

| Chave do VS Code | Efeito no Neovim |
| :--- | :--- |
| `editor.tabSize` / `editor.insertSpaces` | `tabstop`, `shiftwidth`, `expandtab` (só quando definidos explicitamente; `.editorconfig` tem prioridade, igual ao VS Code) |
| `editor.formatOnSave` | Opt-in por projeto: `:ProjectAutoformat project` (global continua `vim.g.autoformat = false`) |
| `editor.defaultFormatter` | Só atua quando é `biomejs.biome`; formatadores internos do VS Code (JSON/HTML) são avisados e ignorados |
| `editor.codeActionsOnSave` | `source.fixAll.biome` / `source.organizeImports.biome` via LSP (resolve + apply) |

**Não portado** (não existe no Neovim/`tsc --lsp`): `js/ts.*` (maxMemory, suggest.*, updateImportsOnFileMove, code actions `*.ts`), `workbench.colorCustomizations`, `files.autoSave`, `quickSuggestions` e os formatadores internos de JSON/HTML.

### 6.2 Comandos

| Comando | Função |
| :--- | :--- |
| `:ProjectInfo` | Mostra raiz, settings, formatter, ações do Biome, indentação e autoformat efetivo do buffer |
| `:ProjectAutoformat [on\|off\|project\|status]` | Override da sessão: `project` segue `editor.formatOnSave`; sem argumento mostra o status |
| `:ProjectReload` | Limpa o cache (útil quando o time altera o `settings.json` com o Neovim aberto) |

O `<leader>cf` replica o “save” do VS Code: `source.organizeImports.biome` → `source.fixAll.biome` → `textDocument/formatting`, sempre só com o Biome (o `biome.json` continua sendo a fonte de verdade). Fora de um projeto com `.vscode`, mantém o comportamento antigo.

### 6.3 Gotchas já validados

1. **`noUnusedImports` é fix unsafe**: nem o VS Code nem esta config removem imports não usados ao salvar. O `biome check --write` também não remove (só com `--unsafe`).
2. **`fixAll` do Biome inclui o organize**: com `assist.actions.source.organizeImports: "on"` no `biome.json`, o LSP retorna uma única ação `source.fixAll.biome`; ela precisa de `codeAction/resolve` antes de aplicar o edit.
3. **Capabilities dinâmicas**: o Biome registra formatação/code actions alguns milissegundos depois do `initialize`; o módulo espera até 1s no primeiro arquivo da sessão.
4. **`.editorconfig` vence `.vscode`**: testado com `tabSize=8` no `.vscode` e `indent_size=2` no `.editorconfig`; o resultado foi 2, igual ao VS Code. Por isso foi criado `Application/Remota.Safe.Application.UI/.editorconfig` (`root = true`, 2 espaços, LF, UTF-8).
5. O `settings.json` do projeto tem **vírgula final** após `"[html]"` — `vim.json.decode` puro falha; o sanitizador remove comentários/vírgulas finais sem tocar em strings.
