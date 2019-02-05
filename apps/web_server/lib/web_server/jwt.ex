defmodule WebServer.Jwt do
  @moduledoc false
  import Joken

  @demo_username "admin"
  @demo_password "sample123"
  @demo_sign "sign123"
  def gen_token(username, password) do
    user = %{username: username, password: password}

    user
    |> token()
    |> with_signer(hs256(@demo_sign))
    |> with_exp(gen_exp())
    |> sign
    |> get_compact
  end

  def validate(authorization) do
    %{claims: claims, error: error} =
      authorization
      |> token
      |> with_validation("username", &(&1 == @demo_username))
      |> with_validation("password", &(&1 == @demo_password))
      |> with_validation("exp", &(&1 >= now_to_unix()))
      |> with_signer(hs256(@demo_sign))
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
