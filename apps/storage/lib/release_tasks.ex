defmodule Storage.ReleaseTasks do
  alias Ecto.Migrator

  @otp_app :storage

  def migrate do
    {:ok, _} = Application.ensure_all_started(@otp_app)
    path = Application.app_dir(@otp_app, "priv/repo/migrations")
    Migrator.run(Storage.Repo, path, :up, all: true)
  end
end
