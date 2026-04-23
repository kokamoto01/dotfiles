-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Quit Neovim when the last editor window is closed
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    local wins = vim.api.nvim_list_wins()
    local real_wins = 0
    for _, win in ipairs(wins) do
      local buf = vim.api.nvim_win_get_buf(win)
      local bt = vim.bo[buf].buftype
      local ft = vim.bo[buf].filetype
      local cfg = vim.api.nvim_win_get_config(win)
      -- Skip floating windows, terminals, sidebars
      if cfg.relative == "" and bt ~= "terminal" and bt ~= "nofile" and ft ~= "snacks_picker_list" then
        real_wins = real_wins + 1
      end
    end
    if real_wins <= 1 then
      vim.cmd("qall")
    end
  end,
})
