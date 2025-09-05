local constants = require("scrub.constants")
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
  vim.api.nvim_set_current_buf(buf or 0)
  -- line is optional when using with :ScrubEnter
  if line ~= nil then
    vim.api.nvim_win_set_cursor(0, { line, 0 })
  end
end


M.reset_buffer = function(buf)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
end

--- Checks if a file exists and creates it if not
--- @param path string
--- @return boolean, boolean
M.ensure_file = function(path)
  local file = io.open(path, "r")

  if file then
    file:close()
    return true, false -- exists, did not create
  else
    file = io.open(path, "w")
    if file then
      file:close()
      return false, true -- does not exists, created
    else
      error("Could not create file: " .. path)
    end
  end
end

return M
