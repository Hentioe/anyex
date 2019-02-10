defmodule Storage.Repo do
  use Ecto.Repo,
    otp_app: :storage,
    adapter: Ecto.Adapters.Postgres

  @prefix "ANYEX_DB_"
  @config_vars [
    database: "#{@prefix}NAME",
    username: "#{@prefix}USERNAME",
    password: "#{@prefix}PASSWORD",
    hostname: "#{@prefix}HOSTNAME"
  ]
  def init(_type, configs) do
    from_env_var_configs =
      @config_vars
      |> Enum.map(fn {key, var_name} ->
        val = System.get_env(var_name)
        if val != nil, do: {key, val}, else: nil
      end)
      |> Enum.filter(fn var -> var != nil end)

    configs = Keyword.merge(configs, from_env_var_configs)
    {:ok, configs}
  end

  def delete_from!(table_name) when is_atom(table_name) do
    table_name = Atom.to_string(table_name)

    Ecto.Adapters.SQL.query!(
      __MODULE__,
      ~s/DELETE FROM "#{table_name}" AS #{String.at(table_name, 0)}0/
    )
  end
end
