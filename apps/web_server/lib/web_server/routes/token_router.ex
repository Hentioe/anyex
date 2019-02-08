defmodule WebServer.Routes.TokenRouter do
  @moduledoc false
  use WebServer.Router, :json_support

  alias WebServer.Jwt

  @admin_username Application.get_env(:web_server, :admin_username)
  @admin_password Application.get_env(:web_server, :admin_password)

  post "/gen" do
    login_info = conn.body_params |> string_key_map

    r =
      try do
        %{username: @admin_username, password: @admin_password} = login_info
        token = Jwt.gen_token(login_info.username, login_info.password)
        {:ok, token}
      rescue
        e in _ -> {:error, e}
      end

    conn |> resp(r)
  end

  use WebServer.RouterHelper, :default_routes
end
