defmodule WebServer do
  @moduledoc """
  应用入口/监督树管理
  """
  use Application
  alias WebServer.Config.Helper, as: ConfigHelper
  alias WebServer.Config.Store, as: ConfigStore

  def start(_type, _args) do
    configs = ConfigHelper.init()
    port = configs |> Map.get(ConfigHelper.gen_key(:web_server, :port))

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
