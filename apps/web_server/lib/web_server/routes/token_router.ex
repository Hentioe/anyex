defmodule WebServer.Routes.TokenRouter do
  @moduledoc false
  use WebServer.Router, :json_support

  alias WebServer.Jwt

  post "/gen" do
    login_info = conn.body_params |> string_key_map

    r =
      try do
        %{username: "admin", password: "sample123"} = login_info
        token = Jwt.gen_token(login_info.username, login_info.password)
        {:ok, token}
      rescue
        e in _ -> {:error, e}
      end

    conn |> resp(r)
  end

  use WebServer.RouterHelper, :default_routes
end
