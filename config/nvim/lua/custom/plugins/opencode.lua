return {
  {
    'nickjvandyke/opencode.nvim',
    version = '*',
    config = function()
      vim.o.autoread = true
    end,
    keys = {
      { '<leader>ac', function() require('opencode').toggle() end, desc = 'Toggle OpenCode' },
      { '<leader>af', function() require('opencode').focus() end, desc = 'Focus OpenCode' },
      { '<leader>ar', function() require('opencode').command('session.select') end, desc = 'Resume/Select session' },
      { '<leader>am', function() require('opencode').command('agent.cycle') end, desc = 'Cycle agent/model' },
      { '<leader>ab', function() require('opencode').prompt('@buffer ') end, desc = 'Add current buffer' },
      { '<leader>as', function() require('opencode').ask('@this: ') end, mode = 'v', desc = 'Send to OpenCode' },
      { '<leader>as', function() require('opencode').ask('@this: ') end, desc = 'Ask OpenCode' },

      { '<leader>aa', function() require('opencode').command('session.redo') end, desc = 'Accept diff' },
      { '<leader>ad', function() require('opencode').command('session.undo') end, desc = 'Deny diff' },

      { '<S-C-u>', function() require('opencode').command('session.half.page.up') end, desc = 'Scroll OpenCode up' },
      { '<S-C-d>', function() require('opencode').command('session.half.page.down') end, desc = 'Scroll OpenCode down' },
    },
  },
}