# 🚀 LazyVim Custom Config

Uma configuração do Neovim limpa, moderna e altamente otimizada, baseada no framework **[LazyVim](https://github.com/LazyVim/LazyVim)** com atalhos de produtividade e integrações inteligentes personalizadas.

---

## 📂 Estrutura do Projeto

```text
~/.config/nvim/
├── init.lua                 # Ponto de entrada (carrega lua/config/lazy.lua)
├── lazyvim.json             # Estado dos extras ativados via :LazyExtras
├── lazy-lock.json           # Lockfile de controle de versão dos plugins
├── LICENSE                  # Licença
├── README.md                # Este README
├── stylua.toml              # Formatação do StyLua
└── lua/
    ├── config/
    │   ├── autocmds.lua     # Comandos automáticos (sincronização de arquivos externos)
    │   ├── keymaps.lua      # Atalhos globais personalizados (Ctrl+S, Ctrl+A, Alt+Setas...)
    │   ├── lazy.lua         # Bootstrapping do lazy.nvim e plugins do LazyVim
    │   └── options.lua      # Configurações do Neovim (shell do Windows e Neovide)
    └── plugins/
        ├── colorscheme.lua  # Tema Gruvbox personalizado (com fundo transparente)
        ├── diagnostics.lua  # Diagnósticos inline modernos (tiny-inline-diagnostic.nvim)
        ├── example.lua      # Arquivo de exemplo para declarar novos plugins customizados
        └── formatting.lua   # Lógica inteligente de formatação (Biome vs Prettier)
```

---

## ✨ Recursos & Customizações

### 📦 Gerenciamento Moderno de Plugins
*   **Lazy Loading**: Plugins carregados assincronamente sob demanda, mantendo o startup instantâneo (< 30ms).
*   **Controle e Estabilidade**: Lockfile (`lazy-lock.json`) para congelar versões e evitar quebra por atualizações de terceiros.
*   **LazyVim Extras**: Ative suporte a linguagens (como Tailwind, Rust, TypeScript) ou ferramentas visuais instantaneamente com `:LazyExtras`.

### 🔄 Sincronização Inteligente com o Disco (Integração com Git/agy)
*   **Autoreload automático**: O Neovim detecta e recarrega arquivos que foram editados externamente (ex: pelo **Antigravity / agy** ou `git checkout`) assim que você foca o editor ou entra em um buffer, contanto que não haja conflitos não salvos.

### 🎨 Formatação de Código Dinâmica
*   O plugin de formatação (`conform.nvim`) foi configurado de forma inteligente em `lua/plugins/formatting.lua`:
    *   Usa **Biome** se detectar um arquivo `biome.json` ou `biome.jsonc` na raiz do projeto.
    *   Cai de volta (**fallback**) para o **Prettier** se o Biome não estiver configurado para o projeto corrente.

---

## ⌨️ Atalhos Personalizados Principais

| Atalho | Modo | Ação |
| :--- | :---: | :--- |
| `Ctrl + A` | Normal / Visual | Seleciona todo o conteúdo do arquivo |
| `Ctrl + S` | Normal / Insert / Visual | **Salva o arquivo sem formatar** (ignora autocmds) |
| `:w` | Linha de comando | **Salva e formata** o arquivo atual (padrão) |
| `:wa` ou `:wall` | Linha de comando | **Formata e salva todos os buffers** abertos e modificados |
| `Ctrl + C` | Visual | Copia a seleção para a área de transferência do sistema |
| `Ctrl + V` | Insert / Visual | Cola da área de transferência do sistema (livre em Normal para não quebrar splits no explorador) |
| `Alt + ⬆️/⬇️/⬅️/➡️` | Todos | **Redimensiona painéis de janelas** (evita conflito do `Ctrl+Setas` no Windows Terminal) |

---

## 🚀 Como Começar

### Pré-requisitos
*   Neovim **0.9.0+**
*   Git
*   Uma [Nerd Font](https://www.nerdfonts.com/) instalada (ex: JetBrainsMono Nerd Font)
*   Ripgrep & FD (para o buscador fuzzy Telescope funcionar perfeitamente)

### Instalação no PC Novo
1.  Faça o backup de qualquer configuração atual do Neovim:
    ```powershell
    # Windows (PowerShell)
    Rename-Item -Path $env:LOCALAPPDATA\nvim -NewName nvim.backup
    ```
2.  Clone o repositório oficial na pasta correta:
    ```powershell
    # Windows (PowerShell)
    git clone https://github.com/henriwasd/nvim.git $env:LOCALAPPDATA\nvim
    ```
3.  Inicie o Neovim! Ele baixará automaticamente o `lazy.nvim`, o core do `LazyVim` e todos os plugins listados:
    ```powershell
    nvim
    ```
