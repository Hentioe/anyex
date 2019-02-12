use Mix.Config

config :web_server,
  port: 4001,
  username: "admin",
  password: "admin123",
  secret: "PZgMUvcbgR",
  default_limit: 50,
  markdown_enables: [:article, :tweet],
  cors_origins: ["*"]
