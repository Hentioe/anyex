defmodule WebServer.Routes.TokenRouter do
  @moduledoc false
  use WebServer.Router, :json_support

  alias WebServer.Token

  post "/gen" do
    login_info = conn.body_params
    ru = login_info |> Map.get("username")
    rp = login_info |> Map.get("password")

    validite_r =
      if ru && rp do
        username = ConfigStore.get(:web_server, :username)
        password = ConfigStore.get(:web_server, :password)

        if ru == username && rp == password do
          {:ok, Token.generate(username, password)}
        else
          {:error, "invalid authentication information"}
        end
      else
        {:error, "incomplete authentication information"}
      end

    case validite_r do
      {:error, msg} ->
        conn |> resp_error(msg)

      {:ok, {:ok, token}} ->
        conn |> resp({:ok, %{token: token}})

      {:ok, {:error, reason}} ->
        conn |> resp_error(reason)
    end
  end

  use WebServer.RouterHelper, :default_routes
end
