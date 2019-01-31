defmodule StorageTest do
  use ExUnit.Case
  doctest Storage

  test "greets the world" do
    assert Storage.hello() == :world
  end
end
