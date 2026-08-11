return {
  {
    'Mofiqul/dracula.nvim',
    lazy = false,
    priority = 1000,
    name = 'dracula',
    config = function()
      vim.cmd.colorscheme('dracula')
      -- Dim the directory path in Snacks' pickers. dracula.nvim exposes its
      -- palette through `colors()` rather than a global; `comment` is its
      -- muted grey. (This previously read `palette.subtle`, which threw
      -- "attempt to index global 'palette'" every startup -- `subtle` is a
      -- rose-pine palette name and dracula has no such key.)
      local palette = require('dracula').colors()
      vim.api.nvim_set_hl(0, 'SnacksPickerDir', { fg = palette.comment })
    end,
  },
}
