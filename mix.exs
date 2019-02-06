defmodule AnyEx.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp aliases do
    [
      "db.create": "ecto.create",
      "db.migrate": "cmd --app storage mix db.migrate",
      "db.rollback": "cmd --app storage mix db.rollback",
      "db.reinit": "cmd --app storage mix db.reinit",
      "db.test": "cmd --app storage mix test",
      "server.test": "cmd --app web_server mix test"
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false}
    ]
  end
end
