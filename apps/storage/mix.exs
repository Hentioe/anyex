defmodule Storage.MixProject do
  use Mix.Project

  def project do
    [
      app: :storage,
      version: "0.1.4-dev",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Storage, []},
      extra_applications: [:logger]
    ]
  end

  defp aliases do
    [
      "gen.migration": "ecto.gen.migration",
      "db.migrate": "ecto.migrate",
      "db.rollback": "ecto.rollback",
      "db.reinit": ["ecto.drop", "ecto.create", "ecto.migrate"]
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, "~> 0.14.1"},
      {:jason, "~> 1.1"}
    ]
  end
end
