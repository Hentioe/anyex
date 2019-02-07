defmodule WebServerTest.Router.ArticleRouterTest do
  use WebServer.Test.Case

  test "add and update article", state do
    conn = conn(:post, "/category/admin", %{qname: "c1", name: "类别1"})
    conn = conn |> put_json_header |> put_authorization(state) |> call

    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    c1 = r.data

    [tag1, tag2, tag3] =
      1..3
      |> Enum.map(fn i ->
        conn = conn(:post, "/tag/admin", %{qname: "t#{i}", name: "标签#{i}"})
        conn = conn |> put_json_header |> put_authorization(state) |> call
        assert conn.status == 200
        r = conn |> resp_to_map
        assert r.passed
        r.data
      end)

    conn =
      conn(:post, "/article/admin", %{
        qtext: "i-am-first-article",
        title: "我是第一篇文章",
        category: c1,
        tags: [%{id: tag1.id}, %{id: tag2.id}, %{id: tag3.id}]
      })

    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    a1 = r.data
    assert length(a1.tags) == 3

    conn = conn(:put, "/article/admin", %{id: a1.id, tags: [%{id: tag1.id}]})
    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    a1 = r.data
    assert length(a1.tags) == 1
  end

  test "find article list", state do
    conn = conn(:post, "/category/admin", %{qname: "c1", name: "类别1"})
    conn = conn |> put_json_header |> put_authorization(state) |> call

    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    c1 = r.data

    [tag1, tag2, tag3] =
      1..3
      |> Enum.map(fn i ->
        conn = conn(:post, "/tag/admin", %{qname: "t#{i}", name: "标签#{i}"})
        conn = conn |> put_json_header |> put_authorization(state) |> call
        assert conn.status == 200
        r = conn |> resp_to_map
        assert r.passed
        r.data
      end)

    _created_list =
      1..15
      |> Enum.map(fn i ->
        conn =
          conn(:post, "/article/admin", %{
            qtext: "i-am-article-#{i}",
            title: "我是第 #{i} 篇文章",
            category: c1,
            tags: [%{id: tag1.id}, %{id: tag2.id}, %{id: tag3.id}]
          })

        conn = conn |> put_json_header |> put_authorization(state) |> call
        assert conn.status == 200
        r = conn |> resp_to_map
        assert r.passed
        r.data
      end)

    conn = conn(:get, "/article/list")
    conn = conn |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    list = r.data
    assert length(list) == 15
    a1 = list |> Enum.at(0)
    assert a1.content == "[NotLoaded]"

    conn = conn(:put, "/article/admin/hidden/#{Enum.at(list, 0).id}")
    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    conn = conn(:delete, "/article/admin/#{Enum.at(list, 1).id}")
    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    conn = conn(:get, "/article/list?offset=1")
    conn = conn |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    list = r.data
    assert length(list) == 12

    conn = conn(:get, "/article/admin/list")
    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    list = r.data
    assert length(list) == 15
  end

  test "find article", state do
    conn = conn(:post, "/category/admin", %{qname: "c1", name: "类别1"})
    conn = conn |> put_json_header |> put_authorization(state) |> call

    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    c1 = r.data

    [tag1, tag2, tag3] =
      1..3
      |> Enum.map(fn i ->
        conn = conn(:post, "/tag/admin", %{qname: "t#{i}", name: "标签#{i}"})
        conn = conn |> put_json_header |> put_authorization(state) |> call
        assert conn.status == 200
        r = conn |> resp_to_map
        assert r.passed
        r.data
      end)

    conn =
      conn(:post, "/article/admin", %{
        qtext: "i-am-article",
        title: "我是第一篇文章",
        category: c1,
        content: "# 前言",
        tags: [%{id: tag1.id}, %{id: tag2.id}, %{id: tag3.id}]
      })

    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    article = r.data

    conn = conn(:get, "/article/query/#{article.qtext}") |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    assert r.data != nil
    assert r.data.content == "<h1>前言</h1>\n"

    conn = conn(:delete, "/article/admin/#{article.id}") |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed

    conn = conn(:get, "/article/query/#{article.qtext}") |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    assert r.data == nil

    conn = conn(:get, "/article/admin/#{article.id}") |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    assert r.data != nil
    assert r.data.content == "# 前言"
  end
end
