return {
  {
    'm9p909/neovim-ai-editing',
    config = function()
      require('myai').setup({
	  endpoint = "https://opencode.ai/zen/go/v1/chat/completions",
	  model = "deepseek-v4-flash",
	  api_key_env_var = "OPENCODE_GO_API_KEY",
	  max_tokens = 32768,
	  temperature = 0,
	  timeout = 120,
      })
    end,
  },
}
