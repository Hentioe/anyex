defmodule WebServer.CommonTest do
  use ExUnit.Case

  import WebServer.Common

  test "test path fixed" do
    raw = ~s|我是一串中文，我来测试标题：你好吗？我感觉不太好啊。|
    fixed = path_fixed(raw)
    assert fixed == "我是一串中文-我来测试标题-你好吗-我感觉不太好啊"

    raw = ~s|I'm an Elixir developer, this is a very helpful language!|
    fixed = path_fixed(raw)
    assert fixed == "I-m-an-Elixir-developer-this-is-a-very-helpful-language"
  end
end
