local view = require("scrub.view")
local utils = require("scrub.utils")

local M = {}

local augroup = vim.api.nvim_create_augroup("Scrub", { clear = true })

M.main = function()
  view.view_buffer(augroup)
end

M.register = function()
  vim.api.nvim_create_user_command("Scrub", M.main, {})
end


---@class SaveNRestoreConfig
---@field enabled boolean
---@field temp boolean

---@class DefaultConfig
---@field enabled boolean
---@field save_n_restore SaveNRestoreConfig

---@type DefaultConfig
local default_config = {
  enabled = true,
  save_n_restore = {
    enabled = true,
    temp = true
  }
}

---@param config DefaultConfig
M.setup = function(config)
  config = config or {}
  config = vim.tbl_deep_extend('keep', config, default_config)

  -- handle configuration
  if config.enabled then
    vim.api.nvim_create_autocmd("VimEnter",
      { group = augroup, desc = "Scrub.nvim setup", once = true, callback = M.register })
  end

  if config.save_n_restore.enabled then
    vim.api.nvim_create_autocmd("VimLeave", {
      group = augroup,
      desc = "Save buffers",
      callback = function()
        utils.save_buffers(config)
      end
    })
    -- vim.api.nvim_create_autocmd("VimEnter",
    --   { group = augroup, desc = "Restore buffers", callback = utils.restore_buffers })
  end
end

return M
