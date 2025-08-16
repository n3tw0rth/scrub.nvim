--- to use with  keymaps and other user facing actions
local helpers = require("lua.helpers")
local utils = require("lua.utils")
local M = {}

M.enter_buffer = function()
  if helpers.is_the_plugin_buffer() then
    local cursor_pos = vim.api.nvim_win_get_cursor(0)[1]

    --- FIXME: cursor_pos-1 is intentional. when writing buffer names to the scratch buffer
    --- a mysterious blank line appears, that cause the buff line to offset by 1
    local buffer = utils.find_buffer_from_ls(cursor_pos)
    vim.api.nvim_set_current_buf(buffer)
  end
end


return M
