local commands = require("scrub.commands")
local constants = require("scrub.constants")
local M = {}

--- extracts the file name from the :ls output line
--- @param line string
--- @return string
M.extract_file_name_from_ls = function(line)
  return line:match('"([^"]+)"')
end

--- Return a table of file names from the :ls output line
--- @return string[]
M.get_listed_buffers = function()
  local ls = vim.split(commands.ls(), "\n")
  local lines = {}
  for _, line in ipairs(ls) do
    local name = M.extract_file_name_from_ls(line)
    if name ~= nil then
      table.insert(lines, name)
    end
  end
  return lines
end

--- extract all information from the :ls output line
--- @param line string
--- @return table
M.extract_all_from_ls = function(line)
  local tokens = {}
  local indicators = {}

  local indicator_slice = string.sub(line, 1, 6)
  local meta_slice = string.sub(line, 6, -1)
  local meta_table = {}

  --- sets the default to prevent nil
  indicators["modifiable_off"] = false
  indicators["is_terminal"] = false
  indicators["modified"] = true
  indicators["has_errors"] = false
  indicators["unlisted"] = false
  indicators["is_cur_window"] = false
  indicators["file"] = nil
  indicators["buf_number"] = nil
  indicators["line"] = nil

  indicators["buf_number"] = indicator_slice:match("%d+")

  for value in meta_slice:gmatch("%S+") do
    table.insert(meta_table, value)
  end

  indicators["file"] = meta_table[1]:gsub('"', "")
  indicators["line"] = meta_table[3]

  return indicators
end

--- Get a table of lines from the :ls output
--- @return table
M.get_ls_lines = function()
  return vim.split(commands.ls(), "\n")
end

--- Get a table of lines from the :ls! output
--- @return table
M.get_ls_all_lines = function()
  return vim.split(commands.ls_all(), "\n")
end

--- find the buffer number from the :ls output line by the provided index
--- @return number?
M.find_buffer_from_ls = function(index)
  local ls = M.get_ls_lines()
  return tonumber(M.extract_all_from_ls(ls[index])["buf_number"])
end

--- find the buffer number from the :ls! output line by the provided index
--- @return number?
M.find_buffer_from_ls_by_name = function(name)
  local ls = M.get_ls_all_lines()
  for _, value in ipairs(ls) do
    if value:match(name) then
      local buf_number = tonumber(M.extract_all_from_ls(value)["buf_number"])
      return buf_number
    end
  end
end


M.unload_buffer_if_empty = function(buf)
  local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if buf_lines[1] ~= nil then
    vim.api.nvim_buf_delete(buf, { force = true })
    vim.api.nvim_win_close(0, true) --- we shall close the current window as all the buffers are closed
  end
end


return M
