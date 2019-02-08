use Mix.Config

config :storage, Storage.Repo,
  database: "anyex-prod",
  username: "postgres"

import_config "prod.secret.exs"
