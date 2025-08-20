local view = require("scrub.view")
local keymaps = require("scrub.keymaps")

local M = {}

local augroup = vim.api.nvim_create_augroup("Scrub", { clear = true })

M.main = function()
  view.view_buffer(augroup)
end

M.register = function()
  vim.api.nvim_create_user_command("Scrub", M.main, {})
end

M.setup = function()
  vim.api.nvim_create_autocmd("VimEnter",
    { group = augroup, desc = "Scrub.nvim setup", once = true, callback = M.register })
end

return M
