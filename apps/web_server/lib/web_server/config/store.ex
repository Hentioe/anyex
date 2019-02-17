defmodule WebServer.Config.Store do
  @moduledoc false
  use Agent

  def start_link(configs: configs) when is_map(configs) do
    Agent.start_link(fn -> configs end, name: __MODULE__)
  end

  def get(app, item, default \\ nil) when is_atom(app) and is_atom(item) do
    key = WebServer.Config.Helper.gen_key(app, item)
    val = Agent.get(__MODULE__, &Map.get(&1, key))
    val || default
  end

  def exists(app, item, name) do
    list = get(app, item) || []
    name in list
  end
end
