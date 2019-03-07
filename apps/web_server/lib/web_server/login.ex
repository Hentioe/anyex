defmodule WebServer.Login do
  @moduledoc false

  defmodule HostRecord do
    @moduledoc false
    use Agent

    def start_link(_opts) do
      Agent.start_link(fn -> %{} end, name: __MODULE__)
    end

    def update(key, val) do
      Agent.update(__MODULE__, &Map.put(&1, key, val))
    end

    def get(key) do
      Agent.get(__MODULE__, &Map.get(&1, key))
    end
  end

  defmodule FrequencyLimit do
    @moduledoc false

    alias WebServer.Config.Store, as: ConfigStore

    import WebServer.Common

    def passed?(conn) when is_map(conn) do
      last_login = HostRecord.get(gen_key(conn))
      last_login = last_login || 0
      safe_seconds = ConfigStore.get(:web_server, :security_check)
      unix_now() > last_login + safe_seconds
    end

    def logged(conn) when is_map(conn) do
      :ok = HostRecord.update(gen_key(conn), unix_now())
    end

    def gen_key(conn) do
      conn.remote_ip
      |> Tuple.to_list()
      |> Enum.join(".")
    end
  end
end
