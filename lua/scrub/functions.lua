--- to use with  keymaps and other user facing actions
local helpers = require("scrub.helpers")
local utils = require("scrub.utils")
local commands = require("scrub.commands")
local M = {}

M.enter_buffer = function()
  if helpers.is_the_plugin_buffer() then
    local cursor_pos = vim.api.nvim_win_get_cursor(0)[1] + 1

    local buffer = utils.find_buffer_from_ls(cursor_pos)
    helpers.focus_on_the_selected_buf(buffer)
  end
end

--- TODO: implemented a proper diffing algorithm: https://florian.github.io/diffing/
M.update_buffers = function()
  if helpers.is_the_plugin_buffer() then
    local cur_buf = vim.api.nvim_get_current_buf()
    local cur_bufs = utils.get_listed_buffers()
    local buf_lines = vim.api.nvim_buf_get_lines(cur_buf, 0, -1, false)

    --- HACK: as lua does tables does not have a contains() method,
    --- here concatenate the table and check if the value exists in the string
    for _, buf in ipairs(cur_bufs) do
      if string.find(table.concat(buf_lines, " "), buf) == nil then
        local buf_number = utils.find_buffer_from_ls_by_name(buf)
        if buf_number ~= nil then
          vim.api.nvim_buf_delete(buf_number, { force = true })
        end
      end
    end

    utils.unload_buffer_if_empty(cur_buf)
  end
end


return M
