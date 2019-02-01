defmodule Storage.Application do
  use Application

  def start(_type, _args) do
    children = [
      Storage.Repo
    ]

    opts = [strategy: :one_for_one, name: Storage.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
