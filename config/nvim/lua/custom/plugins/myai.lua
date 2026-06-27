return {
  {
    dir = '~/Documents/myai.nvim',
    config = function()
      require('myai').setup({
	  endpoint = "https://opencode.ai/zen/go/v1/chat/completions",
	  model = "deepseek-v4-flash",
	  api_key = nil,
	  max_tokens = 4096,
	  temperature = 0,
	  timeout = 30,
      })
    end,
  },
}
