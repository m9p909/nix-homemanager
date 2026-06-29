return {
	"m9p909/neovim-ai-editing",
	config = {
	  endpoint = "https://lite-llm.mymaas.net/v1/chat/completions",
	  model = "openai/gemini-3.5-flash",
	  api_key_env_var = "LITE_LLM_KEY",
	  max_tokens = 32768,
	  temperature = 0,
	  timeout = 60,
	}
}
