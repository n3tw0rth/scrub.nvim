local utils = require("lua.utils")
local constants = require("lua.constants")
local commands = require("lua.commands")
local helpers = require("lua.helpers")
local keymaps = require("lua.keymaps")

local M = {}

---@return integer
M.create_the_buffer = function()
  local current_buf = utils.find_buffer_from_ls_by_name(constants.SCRATCH_BUFFER_NAME)

  if current_buf == nil then
    local buf = vim.api.nvim_create_buf(false, false)
    -- name is used to prevent running actions on other buffers
    vim.api.nvim_buf_set_name(buf, constants.SCRATCH_BUFFER_NAME)
    vim.api.nvim_win_set_buf(0, buf)
    return buf
  else
    vim.api.nvim_set_current_buf(current_buf)
    return current_buf
  end
end

--- @return integer
M.view_buffer = function()
  local buf = M.create_the_buffer()
  vim.bo[buf].buftype = 'nofile'

  M.populate_buffer(buf)

  --- Register it here as it requires the buf id
  keymaps.register_keymaps(buf)
  return buf
end

--- @param buf integer
M.populate_buffer = function(buf)
  local ls = vim.split(commands.ls(), "\n")
  helpers.reset_buffer(buf)
  for _, line in ipairs(ls) do
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, { utils.extract_file_name_from_ls(line) })
  end
end

return M
