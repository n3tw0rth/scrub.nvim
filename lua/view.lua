local utils = require("lua.utils")
local commands = require("lua.commands")

local M = {}

--- @return integer
M.view_buffer = function()
  local buf = vim.api.nvim_create_buf(false, true)
  -- vim.api.nvim_buf_set_name(buf, "Scrub")
  vim.api.nvim_win_set_buf(0, buf)

  M.populate_buffer(buf)

  return buf
end

--- @param buf integer
M.populate_buffer = function(buf)
  local ls = vim.split(commands.ls(), "\n")
  for _, line in ipairs(ls) do
    utils.extract_all_from_ls(line)
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, { utils.extract_file_name(line) })
  end
end


return M
