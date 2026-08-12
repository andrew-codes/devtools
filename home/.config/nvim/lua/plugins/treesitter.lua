local langs = {
  'markdown', 'markdown_inline', 'javascript', 'typescript', 'tsx',
  'html', 'css', 'json', 'yaml', 'lua', 'bash', 'nix',
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',  -- master is frozen and doesn't support nvim 0.12+
    build = ':TSUpdate',
    lazy = false,
    config = function()
      require('nvim-treesitter').install(langs)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = langs,
        callback = function() vim.treesitter.start() end,
      })
    end,
  },
  {
    'davidmh/mdx.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    lazy = false,  -- must load eagerly: it's what teaches nvim the .mdx filetype exists
  },
}
