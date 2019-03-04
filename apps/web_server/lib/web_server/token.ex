defmodule WebServer.Token do
  @moduledoc false
  use Joken.Config

  alias WebServer.Config.Store, as: ConfigStore

  def gen_signer do
    secret = ConfigStore.get(:web_server, :secret)
    suffix = ConfigStore.get(:web_server, :secret_suffix)
    Joken.Signer.create("HS256", "#{secret}.#{suffix}")
  end

  @impl true
  def token_config do
    default_config = default_claims()

    username = ConfigStore.get(:web_server, :username)
    password = ConfigStore.get(:web_server, :password)

    default_config
    |> add_claim("aud", fn -> "Anyex" end)
    |> add_claim("iss", fn -> "Anyex" end)
    |> add_claim("exp", fn -> gen_exp() end, &(&1 >= now_to_unix()))
    |> add_claim("username", fn -> "none" end, &(&1 == username))
    |> add_claim("password", fn -> "none" end, &(&1 == password))
  end

  def generate(username, password) do
    r =
      generate_and_sign(
        %{"username" => username, "password" => password},
        gen_signer()
      )

    case r do
      {:ok, token, _} -> {:ok, token}
      e -> e
    end
  end

  def authorization(token) do
    verify_and_validate(token, gen_signer())
  end

  # Effective time (ms)
  @exp_add_val 60 * 60 * 24 * 45
  defp gen_exp() do
    now_to_unix() + @exp_add_val
  end

  defp now_to_unix do
    DateTime.to_unix(DateTime.utc_now())
  end
end
