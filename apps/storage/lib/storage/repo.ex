defmodule Storage.Repo do
  use Ecto.Repo,
    otp_app: :storage,
    adapter: Ecto.Adapters.Postgres

  def delete_from!(table_name) when is_atom(table_name) do
    Ecto.Adapters.SQL.query!(__MODULE__, "DELETE FROM \"#{Atom.to_string(table_name)}\"")
  end
end
