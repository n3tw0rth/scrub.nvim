local utils = require("scrub.utils")
local constants = require("scrub.constants")
local commands = require("scrub.commands")
local helpers = require("scrub.helpers")
local keymaps = require("scrub.keymaps")
local functions = require("scrub.functions")

local M = {}

---@return integer
M.create_the_buffer = function()
  local current_buf = utils.find_buffer_from_ls_by_name(constants.SCRATCH_BUFFER_NAME)

  if current_buf == nil then
    local buf = vim.api.nvim_create_buf(false, false)
    -- name is used to prevent running actions on other buffers
    vim.api.nvim_buf_set_name(buf, constants.SCRATCH_BUFFER_NAME)
    vim.api.nvim_win_set_buf(0, buf)
    vim.bo[buf].modifiable = true

    return buf
  else
    vim.api.nvim_set_current_buf(current_buf)
    return current_buf
  end
end

--- @param autocmd_group integer
--- @return integer
M.view_buffer = function(autocmd_group)
  local buf = M.create_the_buffer()

  M.populate_buffer(buf)

  --- Register it here as it requires the buf id
  keymaps.register_keymaps(buf)

  --- Add a autocommand to the buffer to listen to :w
  vim.api.nvim_create_autocmd("BufWriteCmd",
    { buffer = buf, callback = functions.update_buffers, group = autocmd_group })

  return buf
end

--- @param buf integer
M.populate_buffer = function(buf)
  local ls = vim.split(commands.ls(), "\n")
  table.remove(ls, 1) --- remove the 1st nil element
  helpers.reset_buffer(buf)
  for index, line in ipairs(ls) do
    local name = utils.extract_file_name_from_ls(line)
    vim.api.nvim_buf_set_lines(buf, index - 1, index - 1, false, { name })
  end
end

return M
