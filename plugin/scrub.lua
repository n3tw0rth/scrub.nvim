vim.api.nvim_create_user_command('ScrubEnter', function()
    require("scrub.functions").enter_buffer()
end, { desc = 'Focus on the selected buffer' })
