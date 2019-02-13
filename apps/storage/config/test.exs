use Mix.Config

import_config "dev.exs"

config :storage, Storage.Repo, log: false
