defmodule WebServer.Routes.TokenRouter do
  @moduledoc false
  use WebServer.Router, :json_support

  alias WebServer.Jwt

  post "/gen" do
    login_info = conn.body_params |> string_key_map

    r =
      try do
        %{username: username, password: password} = login_info
        token = Jwt.gen_token(username, password)
        {:ok, token}
      rescue
        e in _ -> {:error, e}
      end

    conn |> resp(r)
  end

  use WebServer.RouterHelper, :default_routes
end
