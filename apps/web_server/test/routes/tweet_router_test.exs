defmodule WebServerTest.Router.TweetRouterTest do
  use WebServer.TestCase

  test "add and update tweet", state do
    conn =
      conn(:post, "/tweet/admin", %{
        theme: "green",
        content: "推文1"
      })

    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    tweet = conn |> resp_to_map
    assert tweet.theme == "green"
    assert tweet.content == "推文1"

    conn =
      conn(:put, "/tweet/admin", %{
        id: tweet.id,
        theme: "red",
        content: "更新后的推文1"
      })

    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    tweet = conn |> resp_to_map
    assert tweet.theme == "red"
    assert tweet.content == "更新后的推文1"

    conn = conn(:delete, "/tweet/admin/#{tweet.id}")

    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    tweet = conn |> resp_to_map
    assert tweet.res_status == -1

    conn = conn(:put, "/tweet/admin/hidden/#{tweet.id}")

    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    tweet = conn |> resp_to_map
    assert tweet.res_status == 0

    conn = conn(:put, "/tweet/admin/normal/#{tweet.id}")

    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    tweet = conn |> resp_to_map
    assert tweet.res_status == 1
  end

  test "find tweet list", state do
    1..15
    |> Enum.map(fn i ->
      conn =
        conn(:post, "/tweet/admin", %{
          theme: "#FFFFF#{i}",
          content: "# 推文#{i}"
        })

      conn = conn |> put_json_header |> put_authorization(state) |> call
      assert conn.status == 200
      tweet = conn |> resp_to_map
      assert tweet.theme == "#FFFFF#{i}"
      assert tweet.content == "# 推文#{i}"
    end)

    conn = conn(:get, "/tweet/list") |> call
    assert conn.status == 200
    list = conn |> resp_to_map
    assert length(list) == 15

    first_t = list |> Enum.at(0)
    assert first_t.content == "<h1>推文15</h1>\n"

    conn = conn(:delete, "/tweet/admin/#{Enum.at(list, 0).id}")

    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    tweet = conn |> resp_to_map
    assert tweet.res_status == -1

    conn = conn(:post, "/tweet/admin/top/#{Enum.at(list, 10).id}")

    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    top_t = conn |> resp_to_map
    assert top_t.top > -1

    conn = conn(:get, "/tweet/list") |> call
    assert conn.status == 200
    list = conn |> resp_to_map
    assert length(list) == 14
    assert Enum.at(list, 0).id == top_t.id

    conn = conn(:get, "/tweet/admin/list") |> put_authorization(state) |> call
    assert conn.status == 200
    list = conn |> resp_to_map
    assert length(list) == 15
  end
end
