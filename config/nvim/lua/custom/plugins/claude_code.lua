return {
  'nickjvandyke/opencode.nvim',
  version = '*',
  dependencies = { 'folke/snacks.nvim' },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {}
    vim.o.autoread = true

    vim.keymap.set({ 'n', 'x' }, '<leader>ac', function() require('opencode').toggle() end, { desc = 'Toggle opencode' })
    vim.keymap.set({ 'n', 'x' }, '<leader>aa', function() require('opencode').ask('@this: ', { submit = true }) end, { desc = 'Ask opencode' })
    vim.keymap.set({ 'n', 'x' }, '<leader>as', function() require('opencode').select() end, { desc = 'Select opencode action' })
    vim.keymap.set({ 'n', 'x' }, 'go', function() return require('opencode').operator('@this ') end, { desc = 'Add range to opencode', expr = true })
    vim.keymap.set('n', 'goo', function() return require('opencode').operator('@this ') .. '_' end, { desc = 'Add line to opencode', expr = true })
  end,
}
