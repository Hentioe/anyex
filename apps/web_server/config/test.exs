use Mix.Config

import_config "dev.exs"

config :web_server,
  markdown_enables: [:article, :tweet, :comment],
  max_limit: 15,
  security_check: -1
