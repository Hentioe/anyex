defmodule WebServerTest do
  use ExUnit.Case

  @demo_username "admin"
  @demo_password "sample123"
  test "gen jwt token" do
    alias WebServer.Jwt

    _token = Jwt.gen_token(@demo_username, @demo_password)
  end
end
