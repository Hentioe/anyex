defmodule WebServerTest.Router.RootRouterTest do
  use WebServer.TestCase

  test "test ping" do
    conn = conn(:get, "/ping") |> call
    assert conn.status == 200
    assert conn.resp_body == "pong"
  end
end
