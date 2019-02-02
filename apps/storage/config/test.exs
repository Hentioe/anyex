use Mix.Config

config :storage, Storage.Repo,
  database: "anyex-dev",
  username: "postgres",
  password: "sampledb123",
  hostname: "localhost"
