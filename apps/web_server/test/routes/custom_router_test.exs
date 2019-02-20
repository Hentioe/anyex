defmodule WebServerTest.Router.CustomRouterTest do
  use WebServer.TestCase

  test "find tag list", _state do
    conn = conn(:get, "/custom") |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    assert r.data.articles.status == "[NotLoaded]"
    assert r.data.categories.status == "[NotLoaded]"
    assert r.data.tags.status == "[NotLoaded]"
    assert r.data.comments.status == "[NotLoaded]"
    assert r.data.tweets.status == "[NotLoaded]"
    assert r.data.links.status == "[NotLoaded]"

    conn = conn(:get, "/custom?includes=article|category|tag|comment|tweet|link") |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    assert r.data.articles.status == "[Loaded]"
    assert r.data.articles.data != nil
    assert r.data.categories.status == "[Loaded]"
    assert r.data.categories.data != nil
    assert r.data.tags.status == "[Loaded]"
    assert r.data.tags.data != nil
    assert r.data.comments.status == "[Loaded]"
    assert r.data.comments.data != nil
    assert r.data.tweets.status == "[Loaded]"
    assert r.data.tweets.data != nil
    assert r.data.links.status == "[Loaded]"
    assert r.data.links.data != nil
  end
end
