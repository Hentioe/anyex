defmodule WebServerTest.Router.CustomRouterTest do
  use WebServer.TestCase

  test "find tag list", _state do
    conn = conn(:get, "/custom") |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.articles.status == "[NotLoaded]"
    assert r.categories.status == "[NotLoaded]"
    assert r.tags.status == "[NotLoaded]"
    assert r.comments.status == "[NotLoaded]"
    assert r.tweets.status == "[NotLoaded]"
    assert r.links.status == "[NotLoaded]"

    conn = conn(:get, "/custom?includes=article|category|tag|comment|tweet|link") |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.articles.status == "[Loaded]"
    assert r.articles.data != nil
    assert r.categories.status == "[Loaded]"
    assert r.categories.data != nil
    assert r.tags.status == "[Loaded]"
    assert r.tags.data != nil
    assert r.comments.status == "[Loaded]"
    assert r.comments.data != nil
    assert r.tweets.status == "[Loaded]"
    assert r.tweets.data != nil
    assert r.links.status == "[Loaded]"
    assert r.links.data != nil
  end
end
