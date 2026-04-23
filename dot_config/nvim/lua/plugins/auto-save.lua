return {
  "Pocco81/auto-save.nvim",
  event = { "InsertLeave", "TextChanged", "FocusLost" },
  opts = {
    condition = function(buf)
      local fn = vim.fn
      local utils = require("auto-save.utils.data")

      if not (fn.getbufvar(buf, "&modifiable") == 1 and utils.not_in(fn.getbufvar(buf, "&filetype"), {})) then
        return false
      end

      -- Exclude claudecode diff buffers
      local bufname = vim.api.nvim_buf_get_name(buf)
      if bufname:match("%(proposed%)") or bufname:match("%(NEW FILE %- proposed%)") or bufname:match("%(New%)") then
        return false
      end

      if vim.b[buf].claudecode_diff_tab_name or vim.b[buf].claudecode_diff_new_win or vim.b[buf].claudecode_diff_target_win then
        return false
      end

      if fn.getbufvar(buf, "&buftype") == "acwrite" then
        return false
      end

      return true
    end,
  },
}
