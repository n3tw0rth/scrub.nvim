local view = require("lua.view")

local M = {}

local augroup = vim.api.nvim_create_augroup("Scrub", { clear = true })

M.main = function()
  view.view_buffer()
end

M.register_command = function()
  vim.api.nvim_create_user_command("Scrub", M.main, {})
end

M.setup = function()
  vim.api.nvim_create_autocmd("VimEnter",
    { group = augroup, desc = "Scrub.nvim setup", once = true, callback = M.register_command })
end

return { setup = M.setup }
