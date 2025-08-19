local constants = require("lua.constants")
local M = {}

M.is_the_plugin_buffer = function()
  local cur_buf = vim.api.nvim_get_current_buf()
  local cur_buf_name = vim.api.nvim_buf_get_name(cur_buf)

  return string.match(cur_buf_name, constants.SCRATCH_BUFFER_NAME) ~= nil
end

---Focus to the selected buffer and line,
---setting the line number is useful when restoring the buffers
---@param buf number
---@param line? number
M.focus_on_the_selected_buf = function(buf, line)
  --- TODO: also set the cursor to the correct line number
  if buf ~= nil then
    vim.api.nvim_set_current_buf(buf)
  end
end


M.reset_buffer = function(buf)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
end


return M
