local utils = require("scrub.utils")
local helpers = require("scrub.helpers")
local functions = require("scrub.functions")
local M = {}

M.register_keymaps = function(buf)
  vim.api.nvim_create_user_command('ScrubEnter', function()
    functions.enter_buffer()
  end, { desc = 'Focus on the selected buffer' })

  vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", ":ScrubEnter<CR>", { noremap = true, silent = true })
end


return M
