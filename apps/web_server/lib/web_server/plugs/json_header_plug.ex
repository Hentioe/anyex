defmodule WebServer.Plugs.JSONHeaderPlug do
  @moduledoc false
  use WebServer.Conn

  def call(conn, _opts) do
    route_partten = conn.private.plug_route |> elem(0)

    if String.ends_with?(route_partten, "*_path") do
      conn
    else
      conn |> put_resp_content_type("application/json")
    end
  end
end
