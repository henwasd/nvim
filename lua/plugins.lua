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
      { "<leader>f", group = "find" },
      { "<leader>ff", desc = "Find Files" },
      { "<leader>fg", desc = "Live Grep" },
      { "<leader>fb", desc = "Buffers" },
      { "<leader>ft", desc = "Terminal (cwd)" },
      { "<leader>fh", desc = "Help Tags" },
      { "<leader>s", group = "search" },
      { "<leader>sd", desc = "Diagnostics (Workspace)" },
      { "<leader>sD", desc = "Diagnostics (Buffer)" },
      { "<leader>ss", desc = "LSP Document Symbols" },
      { "<leader>sS", desc = "LSP Workspace Symbols" },
      { "<leader>sc", desc = "Commands" },
      { "<leader>sk", desc = "Keymaps" },
      { "<leader>sh", desc = "Command History" },
      { "<leader>sm", desc = "Marks" },
      { "<leader>sr", desc = "Registers" },
      { "<leader>sl", desc = "Buffer Lines" },
      { "<leader>so", desc = "Oldfiles (Recent Files)" },
      { "<leader>st", desc = "Treesitter Nodes" },
      { "<leader>sg", desc = "Git Commits" },
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

  -- 4. Mini Pick (Fuzzy finder ultrarrapido em janela flutuante)
  local ok_pick, pick = pcall(require, "mini.pick")
  if ok_pick then
    pick.setup()
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

  -- 6. Treesitter (syntax highlighting avancado)
  local ok_ts, ts_configs = pcall(require, "nvim-treesitter.configs")
  if ok_ts then
    ts_configs.setup({
      highlight = { enable = true },
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
