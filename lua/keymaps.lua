local utils = require("lua.utils")
local helpers = require("lua.helpers")
local functions = require("lua.functions")
local M = {}

M.register_keymaps = function()
  vim.keymap.set("n", "<CR>", functions.enter_buffer, { noremap = true, silent = true })
end


return M
