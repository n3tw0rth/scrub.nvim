local constants = require("lua.constants")
local M = {}

M.is_the_plugin_buffer = function()
  local cur_buf = vim.api.nvim_get_current_buf()
  local cur_buf_name = vim.api.nvim_buf_get_name(cur_buf)

  return string.match(cur_buf_name, constants.SCRATCH_BUFFER_NAME) ~= nil
end


return M
