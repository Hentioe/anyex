defmodule WebServer do
  @moduledoc """
  应用入口/监督树管理
  """
  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: WebServer.Routes,
        options: [port: 4001]
      )
    ]

    opts = [strategy: :one_for_one, name: WebServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
