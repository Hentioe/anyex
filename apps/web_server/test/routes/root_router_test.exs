defmodule WebServerTest.Router.RootRouterTest do
  use WebServer.TestCase

  test "test ping" do
    conn = conn(:get, "/ping") |> call
    assert conn.status == 200
    assert conn.resp_body == "pong"
  end

  test "test version" do
    conn = conn(:get, "/version") |> call
    assert conn.status == 200
    {:ok, vsn} = :application.get_key(:web_server, :vsn)
    assert conn.resp_body == List.to_string(vsn)
  end
end
