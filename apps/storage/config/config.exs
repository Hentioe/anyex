use Mix.Config

config :storage, ecto_repos: [Storage.Repo]

import_config "#{Mix.env()}.exs"
