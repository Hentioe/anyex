defmodule WebServer.Router do
  @moduledoc false
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def default do
    quote do
      use Plug.Router

      plug :match
      plug :dispatch
    end
  end

  def schema do
    quote do
      use Plug.Router

      alias WebServer.Plugs.{JSONHeaderPlug, JwtAuthPlug}

      plug :match
      plug JSONHeaderPlug
      plug JwtAuthPlug
      plug :dispatch

      def resp_json(conn, body, status \\ 200) when is_integer(status) do
        conn
        |> send_resp(status, Jason.encode!(body))
      end

      def resp_error(conn, reason, code \\ -1) do
        resp_json(conn, %{status: "error", error: %{code: code, reason: to_string(reason)}})
      end

      def fetch_paging_params(conn, limit) do
        conn = conn |> fetch_query_params()
        offset = Map.get(conn.params, "offset", 0)
        limit = Map.get(conn.params, "limit", limit)
        [conn, [offset: offset, limit: limit]]
      end
    end
  end
end
