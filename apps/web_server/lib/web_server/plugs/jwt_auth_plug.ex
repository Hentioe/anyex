defmodule WebServer.Plugs.JwtAuthPlug do
  @moduledoc false
  use WebServer.Conn

  defp resp_json(conn, body, status) when is_integer(status) do
    conn
    |> send_resp(status, Jason.encode!(body))
  end

  def resp_401(conn) do
    conn |> resp_json(%{passed: false, message: "unauthorized", data: nil}, 401)
  end

  @re_admin Regex.compile!("^/[^/]+/admin")
  def call(conn, _opts) do
    if route_to_not_found?(conn) do
      conn
    else
      match_r = @re_admin |> Regex.scan(conn.request_path)

      if length(match_r) > 0 do
        if veryfi_token(conn) do
          conn
        else
          conn |> resp_401 |> halt()
        end
      else
        conn
      end
    end
  end

  def veryfi_token(conn) do
    cookies = Plug.Conn.fetch_cookies(conn).req_cookies

    token = cookies["authorization"] || read_token_from_header(conn)

    if token do
      case WebServer.Jwt.validate(token) do
        {:ok, _} -> true
        {:error, _} -> false
      end
    else
      false
    end
  end

  defp read_token_from_header(conn) do
    header = Plug.Conn.get_req_header(conn, "authorization")

    if length(header) > 0 do
      hd(header)
    else
      nil
    end
  end
end
