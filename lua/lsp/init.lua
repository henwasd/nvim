-- Native LSP Setup (Neovim 0.11 / 0.12+ Native Architecture)
local M = {}

-- Resolve executaveis priorizando o binario local do projeto (node_modules/.bin)
-- e respeitando as extensoes do Windows (.cmd / .exe).
local function find_exec(prefix)
  for _, name in ipairs({ prefix .. ".cmd", prefix .. ".exe", prefix }) do
    if vim.fn.executable(name) == 1 then
      return name
    end
  end
  return nil
end

local function resolve_exec(name, root)
  if root then
    local local_bin = find_exec(vim.fs.joinpath(root, "node_modules", ".bin", name))
    if local_bin then
      return local_bin
    end
  end
  return find_exec(name)
end

-- Major do TypeScript instalado no projeto (ex: 7 para "7.0.2"). Sobe a partir do
-- diretorio do buffer para suportar monorepos/pnpm (node_modules no workspace raiz).
local function workspace_ts_major(root)
  if not root then
    return nil
  end
  local dir = root
  while dir do
    local pkg = vim.fs.joinpath(dir, "node_modules", "typescript", "package.json")
    if vim.uv.fs_stat(pkg) then
      local ok, lines = pcall(vim.fn.readfile, pkg)
      if ok and lines then
        local ok_json, json = pcall(vim.json.decode, table.concat(lines, "\n"))
        if ok_json and type(json) == "table" and type(json.version) == "string" then
          return tonumber(json.version:match("^(%d+)"))
        end
      end
      return nil
    end
    local parent = vim.fs.dirname(dir)
    if parent == dir then
      break
    end
    dir = parent
  end
  return nil
end

function M.setup()
  -- Configuracao visual nativa de diagnosticos
  vim.diagnostic.config({
    virtual_text = {
      prefix = "●",
      spacing = 2,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = "rounded",
      source = "always",
    },
  })

  -- Definicao de icones nos sinais da coluna lateral
  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end

  -- Autocomando executado ao conectar qualquer servidor LSP
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local bufnr = args.buf

      -- Habilita Autocomplete Nativo do Neovim (vim.lsp.completion)
      if client and client:supports_method("textDocument/completion") then
        vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
      end
    end,
  })

  -- Comando utilitario para abrir os logs do LSP diretamente
  vim.api.nvim_create_user_command("LspLog", function()
    local path = vim.lsp.log.get_filename and vim.lsp.log.get_filename() or vim.lsp.get_log_path()
    vim.cmd.edit(path)
  end, { desc = "Open LSP log file" })

  -- Biome (biomejs) para JS/TS/JSON/CSS/HTML - formatter + linter + organize imports.
  -- Normalmente o Biome e instalado POR PROJETO (node_modules/.bin/biome), sem
  -- binario global no PATH, por isso o cmd resolve o local primeiro.
  vim.lsp.config("biome", {
    cmd = function(dispatchers, config)
      local bin = resolve_exec("biome", (config or {}).root_dir) or "biome"
      return vim.lsp.rpc.start({ bin, "lsp-proxy" }, dispatchers)
    end,
  })
  vim.lsp.enable("biome")

  -- TypeScript / JavaScript Language Server (ts_ls) - workspaces com TypeScript < 7 ou projetos JS/Node.js.
  -- O TypeScript 7+ nao fornece tsserver.js; nesses projetos usamos o `tsc` nativo.
  vim.lsp.config("ts_ls", {
    root_dir = function(bufnr, on_dir)
      -- Prioriza tsconfig/jsconfig/package.json mais proximo para suportar subpastas em monorepos (ex: /backend e /desktop-app)
      local root = vim.fs.root(bufnr, { "tsconfig.json", "jsconfig.json", "package.json" })
        or vim.fs.root(bufnr, { ".git" })
      if not root then
        return
      end
      local major = workspace_ts_major(root)
      if major and major >= 7 then
        return
      end
      on_dir(root)
    end,
    cmd = function(dispatchers, config)
      local bin = resolve_exec("typescript-language-server", (config or {}).root_dir)
        or find_exec("typescript-language-server")
        or "typescript-language-server"
      return vim.lsp.rpc.start({ bin, "--stdio" }, dispatchers)
    end,
  })
  vim.lsp.enable("ts_ls")

  -- Rust Analyzer (rust_analyzer) - suporte completo a Rust e Tauri v2 (Cargo, Clippy e Proc Macros)
  if find_exec("rust-analyzer") then
    vim.lsp.config("rust_analyzer", {
      cmd = function(dispatchers, config)
        local bin = resolve_exec("rust-analyzer", (config or {}).root_dir)
          or find_exec("rust-analyzer")
          or "rust-analyzer"
        return vim.lsp.rpc.start({ bin }, dispatchers)
      end,
      root_dir = function(bufnr, on_dir)
        local cargo_root = vim.fs.root(bufnr, { "Cargo.toml" })
        if cargo_root then
          on_dir(cargo_root)
          return
        end
        local git_root = vim.fs.root(bufnr, { ".git" })
        if git_root then
          on_dir(git_root)
        end
      end,
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
            buildScripts = {
              enable = true,
            },
          },
          checkOnSave = true,
          check = {
            command = "clippy",
          },
          procMacro = {
            enable = true,
          },
        },
      },
    })
    vim.lsp.enable("rust_analyzer")
  end

  -- Tailwind CSS (v4) - IntelliSense de classes em JSX/TSX, CSS e HTML.
  -- O projeto RemotaSafe usa Tailwind v4 (CSS-first) com prefixo `tw`; o
  -- servidor detecta o `src/global.css` automaticamente. Limitamos os
  -- filetypes para refletir o `tailwindCSS.enabled` do `.vscode/settings.json`.
  if find_exec("tailwindcss-language-server") then
    vim.lsp.config("tailwindcss", {
      cmd = function(dispatchers, config)
        local bin = resolve_exec("tailwindcss-language-server", (config or {}).root_dir)
          or "tailwindcss-language-server"
        return vim.lsp.rpc.start({ bin, "--stdio" }, dispatchers)
      end,
      filetypes = { "javascriptreact", "typescriptreact", "css", "scss", "html" },
    })
    vim.lsp.enable("tailwindcss")
  end

  -- Typos (typos-lsp) - corretor de erros de digitacao de baixo falso-positivo.
  -- Verifica apenas os buffers abertos; nao precisa de configuracao no projeto.
  if find_exec("typos-lsp") then
    vim.lsp.config("typos_lsp", {
      cmd = function(dispatchers, config)
        local bin = resolve_exec("typos-lsp", (config or {}).root_dir) or "typos-lsp"
        return vim.lsp.rpc.start({ bin }, dispatchers)
      end,
      cmd_env = { RUST_LOG = "typos_lsp=error" },
      filetypes = {
        "c", "cpp", "cs", "css", "scss", "html",
        "javascript", "javascriptreact", "json", "jsonc", "lua",
        "markdown", "python", "rust", "sh", "toml",
        "typescript", "typescriptreact", "yaml", "gitcommit",
      },
      root_dir = function(bufnr, on_dir)
        local root = vim.fs.root(bufnr, {
          "typos.toml", "_typos.toml", ".typos.toml",
          "package.json", ".git",
        })
        if root then
          on_dir(root)
        end
      end,
    })
    vim.lsp.enable("typos_lsp")
  end

  -- Lua Language Server (lua_ls) com globals do Neovim
  if vim.fn.executable("lua-language-server") == 1 or vim.fn.executable("lua-language-server.cmd") == 1 then
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME,
            },
          },
          telemetry = { enable = false },
        },
      },
    })
    vim.lsp.enable("lua_ls")
  end

  -- TypeScript / JavaScript (tsc) - LSP nativo do TypeScript 7+ (`tsc --lsp`).
  -- O config do nvim-lspconfig detecta `tsc`/`tsgo` no workspace ou no PATH e so
  -- atacha se o binario suportar `--lsp` (TypeScript >= 7); caso contrario avisa.
  vim.lsp.enable("tsc")
end

return M
