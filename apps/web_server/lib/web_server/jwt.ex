defmodule WebServer.Jwt do
  @moduledoc false
  import Joken

  @secret_key Application.get_env(:web_server, :secret_key)
  @admin_username Application.get_env(:web_server, :admin_username)
  @admin_password Application.get_env(:web_server, :admin_password)

  def gen_token(username, password) do
    user = %{username: username, password: password}

    user
    |> token()
    |> with_signer(hs256(@secret_key))
    |> with_exp(gen_exp())
    |> sign
    |> get_compact
  end

  def validate(authorization) do
    %{claims: claims, error: error} =
      authorization
      |> token
      |> with_validation("username", &(&1 == @admin_username))
      |> with_validation("password", &(&1 == @admin_password))
      |> with_validation("exp", &(&1 >= now_to_unix()))
      |> with_signer(hs256(@secret_key))
      |> verify

    if error do
      {:error, error}
    else
      {:ok, claims}
    end
  end

  # 45 天有效期
  @exp_add_val 60 * 60 * 24 * 45
  defp gen_exp() do
    now_to_unix() + @exp_add_val
  end

  defp now_to_unix do
    DateTime.to_unix(DateTime.utc_now())
  end
end
