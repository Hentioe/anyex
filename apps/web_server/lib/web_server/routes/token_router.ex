defmodule WebServer.Routes.TokenRouter do
  @moduledoc false
  use WebServer.Router, :json_support

  alias WebServer.Jwt

  post "/gen" do
    login_info = conn.body_params
    ru = login_info |> Map.get("username")
    rp = login_info |> Map.get("password")

    validite_r =
      if ru && rp do
        username = ConfigStore.get(:web_server, :username)
        password = ConfigStore.get(:web_server, :password)

        if ru == username && rp == password do
          {:ok, Jwt.gen_token(username, password)}
        else
          {:error, "invalid authentication information"}
        end
      else
        {:error, "incomplete authentication information"}
      end

    case validite_r do
      {:ok, token} ->
        conn |> resp({:ok, token})

      {:error, msg} ->
        conn |> resp_error(msg)
    end
  end

  use WebServer.RouterHelper, :default_routes
end
