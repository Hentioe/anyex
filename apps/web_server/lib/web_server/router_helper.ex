defmodule WebServer.RouterHelper do
  @moduledoc false
  defmacro __using__(which) do
    apply(__MODULE__, which, [])
  end

  def default_routes do
    quote do
      match _ do
        send_resp(var!(conn), 404, "Not Found")
      end
    end
  end
end
