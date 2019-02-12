use Mix.Config

import_config "dev.exs"

config :web_server,
  markdown_enables: [:article, :tweet],
  default_limit: 15
