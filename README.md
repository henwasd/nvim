# ⚡ Neovim Native High-Performance Config (v0.12+)

Uma configuração do **Neovim (v0.12+)** ultra-otimizada, limpa e moderna, construída utilizando o **máximo de recursos nativos do próprio Neovim** para atingir performance extrema e inicialização instantânea, sem o overhead de frameworks pesados.

---

## 📁 Estrutura do Projeto

```text
~/.config/nvim/ (ou %LOCALAPPDATA%\nvim\)
├── init.lua                 # Ponto de entrada limpo e modular
├── LICENSE                  # Licença
├── README.md                # Esta documentação
├── AGY_INSTRUCTIONS.md      # Instruções de arquitetura para agentes
├── AGY_CONTEXT.md           # Registro completo das decisões e histórico
├── stylua.toml              # Regras de formatação do código Lua
└── lua/
    ├── plugins.lua          # Gerenciamento de plugins nativo via vim.pack (Neovim 0.12)
    ├── config/
    │   ├── options.lua      # Opções nativas e tema retrobox com transparência
    │   ├── keymaps.lua      # Atalhos ergonômicos e atalhos de autocomplete
    │   ├── autocmds.lua     # Sincronização externa de arquivos, highlight yank, etc.
    │   ├── statusline.lua   # Statusline 100% nativa em Lua puro (zero plugins)
    │   ├── terminal.lua     # Terminal flutuante 100% nativo em Lua puro
    │   └── project.lua      # Integração com .vscode/settings.json (indentação, formatOnSave, Biome)
    └── lsp/
        └── init.lua         # LSP nativo (vim.lsp.config), autocomplete nativo e diagnósticos
```

---

## ✨ Principais Recursos & Filosofia Nativa

### 📦 1. Gerenciamento de Pacotes Nativo (`vim.pack`)
*   Zero dependência de gerenciadores externos pesados como `lazy.nvim`.
*   Utiliza a API nativa **`vim.pack`** introduzida no Neovim core:
    *   `:PackUpdate` — atualiza todos os plugins diretamente.
    *   `:PackStatus` — visualiza o status e detalhes dos pacotes instalados.

### ⚡ 2. Autocomplete & Snippets 100% Nativos
*   Alimentado pela engine nativa do Neovim **`vim.lsp.completion`**:
    *   Zero plugins de autocomplete rodando em segundo plano.
    *   Menu de sugestões popup e documentação integrados nativamente.
    *   Suporte a expansão de snippets nativo (`vim.snippet`).
    *   Navegação intuitiva: `<Tab>` e `<S-Tab>` percorrem sugestões ou pulam entre placeholders de snippets, e `<CR>` (Enter) aceita a sugestão.

### 🎨 3. Tema Nativo 'Retrobox' com Transparência
*   Utiliza o **`retrobox`** oficial embutido no binário do Neovim (a recriação oficial do clássico Gruvbox).
*   Zero plugins de tema e zero I/O de disco para carregar o visual.
*   Fundo e painéis transparentes configurados nativamente via API de highlights.

### 📊 4. Statusline Nativa em Lua Puro
*   Renderização em menos de **0.05ms** sem bibliotecas externas.
*   Exibe modo do editor, branch Git atual, nome do arquivo com status de modificação, contadores de diagnóstico LSP (Erros e Avisos), tipo de arquivo e posição do cursor.

### 🖥️ 5. Terminal Flutuante Nativo
*   Janela flutuante centralizada e elegante acionada por atalho (`<C-/>` ou `<leader>ft`).
*   Abre sempre no diretório atual de trabalho (`getcwd()`), perfeito para monorepos e projetos múltiplos.
*   Pressione `<Esc><Esc>` para entrar no modo Normal do terminal.

### 📂 6. Explorador de Arquivos com Oil (`oil.nvim`) + Git Status
*   Edição de diretórios como se fossem buffers de texto padrão do Neovim (`<leader>e`).
*   **Git Status Assíncrono (`oil-git-status.nvim`)**: Exibe as alterações do Git (Stage e Working Tree) diretamente na coluna lateral (`signcolumn`), sem travar a navegação em repositórios grandes.

### 🔍 7. Busca Rápida com Mini.Pick & Mini.Extra (`<leader>f` e `<leader>s`)
*   Fuzzy finder ultra-leve em janela flutuante (`mini.pick`).
*   Integração direta com `ripgrep` (`rg`) e `fd` para velocidade instantânea de busca.
*   **Menu de Busca Geral (`<leader>s`)**: Pesquisa diagnósticos do projeto (`sd`) ou do buffer (`sD`), símbolos LSP (`ss`/`sS`), comandos (`sc`), keymaps (`sk`), histórico (`sh`), arquivos recentes (`so`), marcas (`sm`) e commits (`sg`).

### 🐙 8. Git Integrado de Alta Performance (`<leader>g`)
*   **Vim-Fugitive (`tpope/vim-fugitive`)**: Interface interativa completa sob `<leader>gs` para staging (`s`), unstaging (`u`), visualização de diff (`=`) e commits (`cc`).
*   **Gitsigns (`gitsigns.nvim`)**: Indicadores de alterações em tempo real no gutter (`│`, `_`, `┆`), navegação entre hunks (`]g`/`[g`), visualização de blame (`<leader>gb`) e diff flutuante (`<leader>gp`).

### 🧙‍♂️ 9. Edição Avançada
*   **Surround**: `mini.surround` com prefixo `gz` (`gza` adiciona, `gzd` deleta, `gzr` substitui delimitadores).
*   **Múltiplos Cursores**: `vim-visual-multi` (`Ctrl+N` para selecionar ocorrências).
*   **Which-Key**: Menu visual popup rápido e categorizado ao teclar `<Space>`.

### 🤖 10. Autocompletion com IA (Supermaven)
*   **Supermaven integrado via vim.pack**: Sugestões em linha instantâneas (ghost text) de alta precisão e baixíssimo consumo.
*   **Integração fluida com `<Tab>`**: Aceita a sugestão de IA; se não houver sugestão ativa, navega pelo menu de completion nativo ou salta placeholders de snippets.
*   Menu dedicado no Which-Key sob `<leader>a` (`<leader>as` status, `<leader>at` toggle, etc.).

---

## ⌨️ Tabela de Atalhos Principais

| Tecla / Atalho | Modo | Ação |
| :--- | :--- | :--- |
| `Espaço` (`<Space>`) | Normal / Visual | Tecla Leader (dispara o menu interativo **Which-Key**) |
| `Ctrl + s` | Normal / Insert / Visual | Salva o arquivo rapidamente (`noautocmd w`) |
| `Ctrl + a` | Normal / Visual | Seleciona todo o conteúdo do buffer (`ggVG`) |
| `Ctrl + c` | Visual | Copia seleção para a área de transferência do sistema (`"+y`) |
| `Ctrl + v` | Visual / Insert | Cola conteúdo da área de transferência (`"+p`) |
| `Alt + Setas` | Todos | Redimensiona a janela ativa horizontal/verticalmente |
| `Ctrl + h/j/k/l` | Normal | Navega entre divisões de janelas |
| `Shift + h` / `Shift + l` | Normal | Alterna entre buffers abertos |
| `<leader>e` | Normal | Abre o explorador de arquivos (**Oil**) com Git Status |
| `<leader>fe` | Normal | Abre o explorador de arquivos (**Oil**) no diretório do arquivo |
| `<leader>fs` | Normal | **Salva** o arquivo atual (`:w`) |
| `<leader>fS` | Normal | **Salva todos** os arquivos modificados (`:wa`) |
| `<leader>fn` | Normal | Cria um **novo arquivo** vazio (`:enew`) |
| `<leader>fr` | Normal | **Renomeia / move** o arquivo atual com prompt interativo |
| `<leader>fd` | Normal | **Apaga** o arquivo atual do disco com confirmação |
| `<leader>fy` | Normal | Copia o **caminho relativo** do arquivo para o clipboard |
| `<leader>fY` | Normal | Copia o **caminho absoluto** do arquivo para o clipboard |
| `<leader>ft` | Normal | Abre o terminal flutuante no diretório do **arquivo atual** |
| `<leader>fR` | Normal | **Recarrega** o arquivo do disco descartando mudanças (`:edit!`) |
| `<leader>sf` | Normal | Busca **arquivos** por nome (MiniPick) |
| `<leader>sg` | Normal | Busca **texto** em todo o projeto (Live Grep) |
| `<leader>sw` | Normal | Busca pela **palavra sob o cursor** |
| `<leader>sb` | Normal | Lista e alterna entre **buffers** |
| `<leader>so` | Normal | Busca arquivos recentes (**Oldfiles**) |
| `<leader>sd` | Normal | Busca **Diagnósticos** do projeto/workspace |
| `<leader>sD` | Normal | Busca **Diagnósticos** do buffer atual |
| `<leader>ss` | Normal | Busca **Símbolos** do documento (LSP) |
| `<leader>sS` | Normal | Busca **Símbolos** no workspace (LSP) |
| `<leader>sc` | Normal | Busca e executa **Comandos do Neovim** |
| `<leader>sk` | Normal | Busca **Atalhos / Keymaps** |
| `<leader>sh` | Normal | Busca no **Histórico de Comandos** |
| `<leader>sm` | Normal | Busca **Marks** |
| `<leader>sr` | Normal | Busca **Registros (Registers)** |
| `<leader>sl` | Normal | Busca linhas no **Buffer Atual** |
| `<leader>sH` | Normal | Busca nas páginas de ajuda (**Help Tags**) |
| `<leader>st` | Normal | Busca nós de sintaxe (**Treesitter**) |
| `<leader>sC` | Normal | Busca commits do **Git** (Pick) |
| `<leader>gs` | Normal | Abre o **Git Status Interativo** (**Fugitive**) |
| `<leader>gb` | Normal | Exibe **Git Blame** completo da linha atual |
| `<leader>gp` | Normal | **Preview do Hunk** flutuante |
| `<leader>gd` | Normal | **Diff** do hunk atual |
| `<leader>gr` | Normal | **Reset (desfazer)** alterações do hunk |
| `<leader>gR` | Normal | **Reset Buffer** (desfaz alterações no arquivo) |
| `<leader>ga` | Normal | **Stage Hunk** (adiciona ao commit) |
| `<leader>gu` | Normal | **Undo Stage Hunk** |
| `<leader>gc` | Normal | Busca e navega em **Git Commits** (Pick) |
| `<leader>gB` | Normal | Lista e troca **Git Branches** (Pick) |
| `<leader>gt` | Normal | Abre **Git Log em Árvore** no terminal |
| `]g` / `[g` | Normal | Navega para o próximo / anterior hunk |
| `<leader>bd` | Normal | Fecha o buffer atual (**Delete Buffer**) |
| `<leader>ca` | Normal / Visual | Ações de código (**Code Action**) |
| `<leader>cf` | Normal | Formata o buffer atual via LSP / Biome |
| `<leader>cr` | Normal | Renomeia símbolo (**LSP Rename**) |
| `<leader>cd` | Normal | Abre janela flutuante de diagnóstico na linha |
| `<leader>cl` | Normal | Informações de saúde do LSP |
| `<leader>a` | Normal | Menu Supermaven IA (`as` status, `at` toggle, `ar` restart, etc.) |
| `gd` / `gD` | Normal | Ir para a Definição / Declaração |
| `K` | Normal | Exibe documentação flutuante (Hover) |
| `[d` / `]d` | Normal | Pula para o diagnóstico anterior / próximo |
| `Tab` | Insert | **Aceita sugestão de IA (Supermaven)** / Próximo item do Autocomplete / Pula Snippet |
| `Ctrl + j` | Insert | Aceita a próxima palavra da sugestão de IA |
| `Ctrl + ]` | Insert | Limpa / descarta sugestão atual de IA |
| `Shift + Tab` | Insert | Sugestão anterior no Autocomplete / Snippet anterior |
| `Enter` | Insert | Aceita sugestão do menu popup do Autocomplete |
| `gza` / `gzd` / `gzr` | Normal / Visual | Adiciona / Deleta / Substitui delimitadores (surround) |

---

## 🧠 Servidores LSP, Formatação e Treesitter

Tudo é configurado via API nativa do Neovim (`vim.lsp.config` / `vim.lsp.enable`) em `lua/lsp/init.lua`:

| Servidor | Quando atacha | Papel |
| :--- | :--- | :--- |
| **`tsc`** (TypeScript nativo) | Projetos com **TypeScript 7+** (`tsc --lsp`) | Tipos, hover, rename, code actions, diagnóstico |
| **`ts_ls`** (typescript-language-server) | Projetos com **TypeScript < 7** | O mesmo, para versões antigas do TS |
| **`biome`** | Projetos JS/TS/JSON/CSS/HTML com `biome.json` | Formatter, linter e organize imports |
| **`tailwindcss`** | Projetos com Tailwind CSS v4 / v3 (classes `tw:`, CSS, JSX/TSX) | IntelliSense, completion e preview de classes |
| **`typos_lsp`** | Buffers de código abertos | Corretor ortográfico de baixo falso-positivo |
| **`lua_ls`** | Somente se `lua-language-server` estiver no PATH | Lua (edição desta config) |

*   O TypeScript 7 **removeu** o `tsserver.js`, então o `ts_ls` clássico quebra nesses projetos. A solução é o **`tsc` nativo**; os dois servidores nunca ficam ativos no mesmo buffer.
*   O `biome` é resolvido **primeiro no projeto** (`node_modules/.bin/biome[.cmd/.exe]`) e só depois no PATH — por isso funciona sem instalação global.
*   `<leader>cf` replica o “save” do VS Code quando há `.vscode/settings.json`: `organizeImports` + `fixAll` do Biome e depois formata (só com o Biome, respeitando o `biome.json`), evitando formatação dupla com o `tsc`.

### 🔗 Configurações do projeto (`.vscode`)

`lua/config/project.lua` lê o `.vscode/settings.json` do projeto em runtime (JSONC) e aplica apenas o que tem equivalente real: `editor.tabSize`, `editor.insertSpaces`, `editor.formatOnSave`, `editor.defaultFormatter` (Biome) e `editor.codeActionsOnSave` (Biome). As chaves `js/ts.*`, `workbench.*` e os formatadores internos de JSON/HTML são intencionalmente ignorados.

| Comando | Função |
| :--- | :--- |
| `:ProjectInfo` | Mostra o que foi resolvido do `.vscode` para o buffer atual |
| `:ProjectAutoformat project` | Passa a formatar ao salvar seguindo `editor.formatOnSave` (a sessão começa em modo manual) |
| `:ProjectAutoformat on\|off\|status` | Override imediato da sessão |
| `:ProjectReload` | Recarrega o cache após o time editar o `settings.json` |

O `.editorconfig` do projeto (2 espaços, LF, UTF-8) tem prioridade sobre o `.vscode`, assim como no VS Code.

### 🌳 Treesitter (highlight + indentação)

*   Syntax highlighting e indentação via **`nvim-treesitter` (branch `main`)**, intencionalmente sem plugins extras.
*   Parsers instalados em `%LOCALAPPDATA%\nvim-data\site\parser` (Linux: `~/.local/share/nvim/site/parser`).
*   Linguagens já configuradas em `lua/plugins.lua`: `bash`, `css`, `diff`, `html`, `javascript`, `json`, `lua`, `luadoc`, `markdown`, `markdown_inline`, `query`, `regex`, `toml`, `tsx`, `typescript`, `vim`, `vimdoc`, `yaml`.
*   Para adicionar outra linguagem: inclua o nome na lista de `lua/plugins.lua` (ou rode `:lua require('nvim-treesitter').install('nome')`).

#### Dependências do Treesitter

1.  **CLI `tree-sitter`** (a branch `main` compila os parsers): `npm install -g tree-sitter-cli`
    *   Se o seu npm tiver `ignore-scripts=true`, o binário não é baixado automaticamente. Rode:
        `node "$(npm root -g)/tree-sitter-cli/install.js"`
2.  **Compilador C** no PATH (`gcc`, `clang` ou `cl`).

> Se o `tree-sitter build` reclamar de *stale lock*, apague `%LOCALAPPDATA%\tree-sitter\lock\*.lock` e tente novamente.