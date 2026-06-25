return {
  {
    'nickjvandyke/opencode.nvim',
    version = '*',
    config = function()
      vim.o.autoread = true
    end,
    keys = {
      { '<leader>ac', function() require('opencode').select() end, desc = 'Select OpenCode' },
      { '<leader>af', function() require('opencode').ask() end, desc = 'Ask OpenCode' },
      { '<leader>am', function() require('opencode').command('agent.cycle') end, desc = 'Cycle agent/model' },
      { '<leader>ab', function() require('opencode').prompt('@buffer ') end, desc = 'Add current buffer' },
      { '<leader>as', function() require('opencode').ask('@this: ') end, mode = 'v', desc = 'Send to OpenCode' },
      { '<leader>aa', function() require('opencode').command('session.redo') end, desc = 'Accept diff' },
      { '<leader>ad', function() require('opencode').command('session.undo') end, desc = 'Deny diff' },

      { '<S-C-u>', function() require('opencode').command('session.half.page.up') end, desc = 'Scroll OpenCode up' },
      { '<S-C-d>', function() require('opencode').command('session.half.page.down') end, desc = 'Scroll OpenCode down' },
    },
  },
}
