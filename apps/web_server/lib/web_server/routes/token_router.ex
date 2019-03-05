defmodule WebServer.Routes.TokenRouter do
  @moduledoc false
  use WebServer.Router, :json_support

  alias WebServer.Token
  alias WebServer.Login.FrequencyLimit
  alias Storage.Schema.SecretSuffix

  post "/gen" do
    if FrequencyLimit.passed?(conn) do
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
          FrequencyLimit.logged(conn)
          conn |> resp({:ok, %{token: token}})

        {:ok, {:error, reason}} ->
          conn |> resp_error(reason)
      end
    else
      conn |> resp_error("failure to pass security check (please reduce frequency)")
    end
  end

  post "/admin/revoke" do
    case SecretSuffix.generate() do
      {:ok, secret_suffix} ->
        suffix = secret_suffix.val
        :ok = ConfigStore.update(:web_server, :secret_suffix, suffix)
        conn |> resp({:ok, %{message: "SUCCESS"}})

      {:error, e} ->
        conn |> resp_error(e)
    end
  end

  post "/admin/refresh" do
    if FrequencyLimit.passed?(conn) do
      username = ConfigStore.get(:web_server, :username)
      password = ConfigStore.get(:web_server, :password)

      case Token.generate(username, password) do
        {:ok, token} ->
          FrequencyLimit.logged(conn)
          conn |> resp({:ok, %{token: token}})

        {:error, e} ->
          conn |> resp_error(e)
      end
    else
      conn |> resp_error("failure to pass security check (please reduce frequency)")
    end
  end

  use WebServer.RouterHelper, :default_routes
end
