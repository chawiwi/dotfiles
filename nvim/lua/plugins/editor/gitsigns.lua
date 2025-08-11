-- lua/plugins/editor/gitsigns.lua
return {
    -- Adds git signs + hunk actions
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPre', -- or "VeryLazy" if you prefer
    opts = {
        signs = {
            add = { hl = 'GitSignsAdd', text = '+', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
            change = { hl = 'GitSignsChange', text = '|', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
            delete = { hl = 'GitSignsDelete', text = '_', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
            topdelete = { hl = 'GitSignsDelete', text = '‾', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
            changedelete = { hl = 'GitSignsChange', text = '~', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
            untracked = { hl = 'GitSignsAdd', text = '┆', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
        },
        current_line_blame = true,
        numhl = true,
        linehl = true,

        -- keep on_attach only if you need buffer-specific behavior
        -- (keymaps live in your mono keymaps file now)
        -- on_attach = function(bufnr)
        --   -- e.g., custom textobjects or buffer-local tweaks
        -- end,
    },
    -- No `config` needed—Lazy will call require("gitsigns").setup(opts) for you
}
