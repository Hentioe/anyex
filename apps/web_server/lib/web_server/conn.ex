defmodule WebServer.Conn do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      import Plug.Conn
      import WebServer.Conn

      def init(opts) do
        opts
      end

      def call(conn, _opts) do
        conn
      end

      defoverridable init: 1
      defoverridable call: 2
    end
  end

  def route_to_not_found?(conn) do
    route_partten = conn.private.plug_route |> elem(0)
    String.ends_with?(route_partten, "*_path")
  end
end
