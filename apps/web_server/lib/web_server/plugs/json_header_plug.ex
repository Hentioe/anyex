defmodule WebServer.Plugs.JSONHeaderPlug do
  @moduledoc false
  use WebServer.Conn

  def call(conn, _opts) do
    if route_to_not_found?(conn) do
      conn
    else
      conn |> put_resp_content_type("application/json")
    end
  end
end
