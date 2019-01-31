defmodule WebServerTest do
  use ExUnit.Case
  doctest WebServer

  test "greets the world" do
    assert WebServer.hello() == :world
  end
end
