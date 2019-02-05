defmodule WebServer.Conn do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      import Plug.Conn

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
end
