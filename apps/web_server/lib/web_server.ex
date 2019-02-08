defmodule WebServer do
  @moduledoc """
  应用入口/监督树管理
  """
  use Application

  def start(_type, _args) do
    port =
      System.get_env("ANYEX_PORT") || Application.get_env(:web_server, :port) ||
        raise "please give me a port parameter!"

    port = if is_integer(port), do: port, else: String.to_integer(port)

    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: WebServer.Routes,
        options: [port: port]
      )
    ]

    opts = [strategy: :one_for_one, name: WebServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
