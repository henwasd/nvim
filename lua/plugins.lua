-- Minimalist Plugin Management via Neovim 0.12 Native vim.pack
local M = {}

M.specs = {
  "https://github.com/folke/which-key.nvim",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/refractalize/oil-git-status.nvim",
  "https://github.com/echasnovski/mini.pick",
  "https://github.com/echasnovski/mini.extra",
  "https://github.com/echasnovski/mini.icons",
  "https://github.com/echasnovski/mini.surround",
  "https://github.com/echasnovski/mini.tabline",
  "https://github.com/catgoose/nvim-colorizer.lua",
  "https://github.com/mg979/vim-visual-multi",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/supermaven-inc/supermaven-nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/tpope/vim-fugitive",
}

function M.setup()
  -- Adiciona plugins na sessao via API nativa vim.pack
  vim.pack.add(M.specs, { confirm = false })

  -- 1. Which-Key (Menu visual instantaneo ao pressionar a tecla Leader <Space>)
  local ok_wk, wk = pcall(require, "which-key")
  if ok_wk then
    wk.setup({
      delay = 150,
      icons = {
        mappings = true,
      },
    })
    wk.add({
      { "<leader>e", desc = "Explorer (Oil)" },
      { "<leader>f", group = "file" },
      { "<leader>fe", desc = "File Explorer (Oil)" },
      { "<leader>fs", desc = "Save File" },
      { "<leader>fS", desc = "Save All Files" },
      { "<leader>fn", desc = "New File" },
      { "<leader>fr", desc = "Rename / Move File" },
      { "<leader>fd", desc = "Delete Current File" },
      { "<leader>fy", desc = "Yank Relative Path" },
      { "<leader>fY", desc = "Yank Absolute Path" },
      { "<leader>ft", desc = "Terminal in File Dir" },
      { "<leader>fR", desc = "Reload File from Disk" },
      { "<leader>s", group = "search" },
      { "<leader>sf", desc = "Search Files (Name)" },
      { "<leader>sg", desc = "Search Text (Live Grep)" },
      { "<leader>sw", desc = "Search Word under Cursor" },
      { "<leader>sb", desc = "Search Buffers" },
      { "<leader>so", desc = "Search Recent Files (Oldfiles)" },
      { "<leader>sd", desc = "Search Diagnostics (Workspace)" },
      { "<leader>sD", desc = "Search Diagnostics (Buffer)" },
      { "<leader>ss", desc = "Search Document Symbols" },
      { "<leader>sS", desc = "Search Workspace Symbols" },
      { "<leader>sc", desc = "Search Commands" },
      { "<leader>sk", desc = "Search Keymaps" },
      { "<leader>sh", desc = "Search Command History" },
      { "<leader>sm", desc = "Search Marks" },
      { "<leader>sr", desc = "Search Registers" },
      { "<leader>sl", desc = "Search Buffer Lines" },
      { "<leader>sH", desc = "Search Help Tags" },
      { "<leader>st", desc = "Search Treesitter Nodes" },
      { "<leader>sC", desc = "Search Git Commits" },
      { "<leader>g", group = "git" },
      { "<leader>gs", desc = "Git Status" },
      { "<leader>gb", desc = "Git Blame Line" },
      { "<leader>gp", desc = "Preview Hunk" },
      { "<leader>gd", desc = "Diff This Hunk" },
      { "<leader>gr", desc = "Reset Hunk" },
      { "<leader>gR", desc = "Reset Buffer" },
      { "<leader>ga", desc = "Stage Hunk" },
      { "<leader>gu", desc = "Undo Stage Hunk" },
      { "<leader>gc", desc = "Git Commits" },
      { "<leader>gB", desc = "Git Branches" },
      { "<leader>gt", desc = "Git Terminal" },
      { "<leader>b", group = "buffer" },
      { "<leader>bd", desc = "Delete Buffer" },
      { "<leader>c", group = "code" },
      { "<leader>ca", desc = "Code Action" },
      { "<leader>cf", desc = "Format Document" },
      { "<leader>cr", desc = "Rename Symbol" },
      { "<leader>cd", desc = "Line Diagnostics" },
      { "<leader>cl", desc = "LSP Info" },
      { "<leader>cc", desc = "Toggle Colorizer" },
      { "<leader>t", group = "terminal" },
      { "<leader>tt", desc = "Toggle Terminal" },
      { "<leader>tn", desc = "New Terminal" },
      { "<leader>tl", desc = "List / Select Terminals" },
      { "<leader>t]", desc = "Next Terminal" },
      { "<leader>t[", desc = "Previous Terminal" },
      { "<leader>tk", desc = "Kill Terminal" },
      { "<leader>tr", desc = "Rename Terminal" },
    })
  end

  -- 2. Mini Icons (icones leves para oil e pick)
  local ok_icons, icons = pcall(require, "mini.icons")
  if ok_icons then
    icons.setup()
  end

  -- 3. Oil.nvim com status do Git assíncrono (oil-git-status)
  local ok_oil, oil = pcall(require, "oil")
  if ok_oil then
    oil.setup({
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
      },
      win_options = {
        signcolumn = "yes:2",
      },
    })

    local ok_oil_git, oil_git = pcall(require, "oil-git-status")
    if ok_oil_git then
      oil_git.setup({
        show_ignored = false,
      })
    end
  end

  -- 4. Mini Pick & Mini Extra (Fuzzy finder ultrarrapido em janela flutuante)
  local ok_pick, pick = pcall(require, "mini.pick")
  if ok_pick then
    pick.setup()
  end
  local ok_extra, extra = pcall(require, "mini.extra")
  if ok_extra then
    extra.setup()
  end

  -- 5. Mini Surround (Manipulacao de aspas/parenteses com prefixo gz)
  local ok_surround, surround = pcall(require, "mini.surround")
  if ok_surround then
    surround.setup({
      mappings = {
        add = "gza",
        delete = "gzd",
        find = "gzf",
        find_left = "gzF",
        highlight = "gzh",
        replace = "gzr",
        update_n_lines = "gzn",
      },
    })
  end

  -- 5.1 Mini Tabline (Barra visual de buffers no topo)
  local ok_tabline, tabline = pcall(require, "mini.tabline")
  if ok_tabline then
    tabline.setup({
      show_icons = true,
      set_as_default = true,
    })
  end

  -- 6. Gitsigns (indicadores Git na coluna lateral e acoes de hunk)
  local ok_gs, gitsigns = pcall(require, "gitsigns")
  if ok_gs then
    gitsigns.setup()
  end

  -- 7. Supermaven (autocompletion de IA de baixa latencia)
  local ok_sm, supermaven = pcall(require, "supermaven-nvim")
  if ok_sm then
    supermaven.setup({
      keymaps = {
        accept_suggestion = nil, -- Gerenciado pelo <Tab> inteligente em keymaps.lua
        clear_suggestion = "<C-]>",
        accept_word = "<C-j>",
      },
    })
  end

  -- 8. Treesitter (branch main - syntax highlighting e indentacao nativos por buffer)
  local ok_ts, ts = pcall(require, "nvim-treesitter")
  if ok_ts and ts.install then
    ts.install({
      "bash",
      "css",
      "diff",
      "html",
      "javascript",
      "json",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "query",
      "regex",
      "rust",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
    })
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("NativeTreesitter", { clear = true }),
    callback = function(args)
      if not pcall(vim.treesitter.start, args.buf) then
        return
      end
      local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
      if lang and #vim.treesitter.query.get_files(lang, "indents") > 0 then
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end,
  })

  -- 9. Colorizer (destaque de cores hex, rgb, hsl, css variables, oklch e tailwind)
  local ok_col, colorizer = pcall(require, "colorizer")
  if ok_col then
    colorizer.setup({
      filetypes = {
        "*",
        css = { names = true, css = true },
        scss = { names = true, css = true },
        sass = { names = true, css = true },
        less = { names = true, css = true },
        html = { names = true, css = true },
      },
      user_default_options = {
        names = false,
        RGB = true,
        RRGGBB = true,
        RRGGBBAA = true,
        AARRGGBB = false,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = "background",
        tailwind = true,
        sass = { enable = true, parsers = { "css" } },
        virtualtext = "■",
      },
    })
  end

  -- Comandos convenientes para gerenciar pacotes nativos
  vim.api.nvim_create_user_command("PackUpdate", function()
    vim.pack.update()
  end, { desc = "Update all plugins via vim.pack" })

  vim.api.nvim_create_user_command("PackStatus", function()
    local list = vim.pack.get()
    vim.print(list)
  end, { desc = "Show plugins managed by vim.pack" })
end

return M
