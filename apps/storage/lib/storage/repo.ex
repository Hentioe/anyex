defmodule Storage.Repo do
  use Ecto.Repo,
    otp_app: :storage,
    adapter: Ecto.Adapters.Postgres

  def delete_from!(table_name) when is_atom(table_name) do
    table_name = Atom.to_string(table_name)

    Ecto.Adapters.SQL.query!(
      __MODULE__,
      ~s/DELETE FROM "#{table_name}" AS #{String.at(table_name, 0)}0/
    )
  end
end
