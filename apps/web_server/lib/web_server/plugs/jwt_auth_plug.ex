defmodule WebServer.Plugs.JwtAuthPlug do
  @moduledoc false
  use WebServer.Conn

  @re_admin Regex.compile!("^/[^/]+/admin")
  def call(conn, _opts) do
    if route_to_not_found?(conn) do
      conn
    else
      match_r = @re_admin |> Regex.scan(conn.request_path)

      if length(match_r) > 0 do
        # 需要验证
        conn
      else
        conn
      end
    end
  end
end
