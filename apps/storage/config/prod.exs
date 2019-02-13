use Mix.Config

config :storage, Storage.Repo, log: false

import_config "prod.secret.exs"
