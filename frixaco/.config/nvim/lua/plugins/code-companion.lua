return {
  {
    'olimorris/codecompanion.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {
      system_prompt = function(opts)
        return [[You are an AI programming assistant specialized in software development. Focus on generating high-quality, secure, and efficient code based on user requests.

**Instructions:**

*   **Code:** Prioritize writing clean, well-commented, idiomatic code. Use specified languages/frameworks correctly.
*   **Security:** Embed security best practices. Flag potential vulnerabilities.
*   **Explanation:** Briefly explain non-obvious code sections or design choices.
*   **Context:** Use provided context and ask for clarification if needed.
*   **Accuracy:** Be accurate. If unsure, state it.
*   **Format:** Use Markdown code blocks for all code snippets.

Respond directly to the user's technical requests.]]
      end,
    },
    config = function()
      require('codecompanion').setup({
        strategies = {
          chat = {
            adapter = 'open_router',
          },
          inline = {
            adapter = 'open_router',
          },
        },
        adapters = {
          open_router = function()
            return require('codecompanion.adapters').extend('openai_compatible', {
              env = {
                url = 'https://openrouter.ai/api',
                api_key = 'OPENROUTER_API_KEY',
                -- api_key = 'cmd:op read op://Personal/LLM/OPENROUTER --no-newline',
                chat_url = '/v1/chat/completions',
                models_endpoint = '/v1/models',
              },
              schema = {
                model = {
                  default = 'anthropic/claude-3.5-sonnet',
                  -- default = 'google/gemini-2.5-pro-exp-03-25:free',
                },
              },
            })
          end,
        },
      })
    end,
  },
}
