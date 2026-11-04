-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- --- AUTORELOAD DE ARQUIVOS ALTERADOS EXTERNAMENTE (ex: por Antigravity / agy) ---
-- Garante que o Neovim recarregue o arquivo silenciosamente assim que o agy ou git fizerem alterações,
-- desde que você não tenha modificações pendentes e não salvas no próprio buffer do Neovim.

vim.opt.autoread = true

local autoreload_group = vim.api.nvim_create_augroup("AutoreloadExternalChanges", { clear = true })

-- Executa `:checktime` para atualizar o buffer ao ganhar foco, entrar no arquivo ou ficar ocioso
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = autoreload_group,
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

-- Notifica caso o arquivo seja atualizado com sucesso em segundo plano
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = autoreload_group,
  callback = function()
    vim.notify("Arquivo atualizado no editor (alterado no disco).", vim.log.levels.INFO, { title = "Antigravity / Git" })
  end,
})
