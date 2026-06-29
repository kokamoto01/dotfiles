-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable window title (ensure it sticks after all plugins load)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.o.title = false
  end,
})

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

-- 外部(Claude の auto モード等)で変更されたファイルを自動で再読込する
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

-- Claude Code(auto モード)が編集したファイルを一括で開く。
-- ~/.claude/settings.json の Stop フックから `nvim --server $NVIM --remote-expr`
-- 経由で、編集パス一覧を書いた listfile のパスを渡して呼ばれる。
function _G.ClaudeOpenEdited(listfile)
  vim.schedule(function()
    local cur = vim.api.nvim_get_current_win() -- 元のフォーカス窓(claude 端末等)
    local ok, lines = pcall(vim.fn.readfile, listfile)
    pcall(vim.fn.delete, listfile) -- 読んだら一時ファイルは削除
    if not ok then
      return
    end
    -- 開く先の窓を選ぶ。フロート/ターミナル/サイドバーは除外。
    -- 通常編集窓(buftype=="")を最優先、無ければダッシュボード等のメイン窓へ。
    local exclude_ft = {
      snacks_picker_list = true,
      snacks_picker_input = true,
      snacks_layout_box = true,
      ["neo-tree"] = true,
    }
    local target, fallback
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local b = vim.api.nvim_win_get_buf(win)
      local cfg = vim.api.nvim_win_get_config(win)
      local bt = vim.bo[b].buftype
      local ft = vim.bo[b].filetype
      if cfg.relative == "" then -- フロートでない
        if bt == "" then
          target = win
          break
        elseif bt ~= "terminal" and not exclude_ft[ft] and not fallback then
          fallback = win -- ダッシュボード等
        end
      end
    end
    target = target or fallback
    if not target then
      -- 最後の手段: 新規 split を作ってそこに開く
      vim.cmd("botright vsplit")
      target = vim.api.nvim_get_current_win()
    end
    local seen = {}
    for _, path in ipairs(lines) do
      if path ~= "" and not seen[path] and vim.fn.filereadable(path) == 1 then
        seen[path] = true
        vim.api.nvim_win_call(target, function()
          vim.cmd("edit " .. vim.fn.fnameescape(path))
          vim.cmd("checktime")
        end)
      end
    end
    -- フォーカスは元の窓(claude 端末)に戻す
    if vim.api.nvim_win_is_valid(cur) then
      vim.api.nvim_set_current_win(cur)
    end
  end)
end
