defmodule WebServer do
  @moduledoc """
  应用入口/监督树管理
  """
  use Application
  alias WebServer.Configure.Helper, as: ConfigHelper
  alias WebServer.Configure.Store, as: ConfigStore

  def start(_type, _args) do
    configs = ConfigHelper.init()
    port = ConfigHelper.get_config!(:web_server, :port)

    port = if is_integer(port), do: port, else: String.to_integer(port)

    children = [
      {ConfigStore, configs: configs},
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
