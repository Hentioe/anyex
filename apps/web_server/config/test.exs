use Mix.Config

import_config "dev.exs"

config :web_server,
  article_markdown_support: true,
  tweet_markdown_support: true,
  default_limit: 15
