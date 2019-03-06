use Mix.Config

config :web_server,
  port: 4001,
  username: "admin",
  password: "admin123",
  default_limit: 25,
  max_limit: 50,
  markdown_enables: [:article, :tweet],
  cors_origins: ["*"],
  token_secret: "demo_secret",
  token_validity: 60 * 60 * 24 * 45,
  security_check: 3,
  path_strategy: :raw
