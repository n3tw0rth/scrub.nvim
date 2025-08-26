# Scrub.nvim

Plugin to close unwanted buffers easily on nvim. (also might include save and restore current buffers like in tmux ressurect)


### Usage 
Tested on neovim 0.11.2 with lazy.nvim

```lua
return {
    {
        "n3tw0rth/scrub.nvim",
        config = function()
            require("scrub").setup()
        end
    }
}
```
Then add the keymap
```lua
map("n", "_", "<CMD>Scrub<CR>", { desc = "Run Scrub" })
```
