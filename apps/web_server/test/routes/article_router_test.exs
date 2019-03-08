defmodule WebServerTest.Router.ArticleRouterTest do
  use WebServer.TestCase

  require Integer

  test "add and update article", state do
    conn = conn(:post, "/category/admin", %{path: "c1", name: "类别1"})
    conn = conn |> put_json_header |> put_authorization(state) |> call

    assert conn.status == 200
    c1 = conn |> resp_to_map

    [tag1, tag2, tag3] =
      1..3
      |> Enum.map(fn i ->
        conn = conn(:post, "/tag/admin", %{path: "t#{i}", name: "标签#{i}"})
        conn = conn |> put_json_header |> put_authorization(state) |> call
        assert conn.status == 200
        conn |> resp_to_map
      end)

    conn =
      conn(:post, "/article/admin", %{
        path: "i-am-first-article",
        title: "我是第一篇文章",
        category: c1,
        tags: [%{id: tag1.id}, %{id: tag2.id}, %{id: tag3.id}]
      })

    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    a1 = conn |> resp_to_map
    assert length(a1.tags) == 3
    assert a1.path == "i-am-first-article"

    conn = conn(:put, "/article/admin", %{id: a1.id, tags: [%{id: tag1.id}]})
    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    a1 = conn |> resp_to_map
    assert length(a1.tags) == 1
  end

  test "find article list", state do
    conn = conn(:post, "/category/admin", %{path: "c1", name: "类别1"})
    conn = conn |> put_json_header |> put_authorization(state) |> call

    assert conn.status == 200
    c1 = conn |> resp_to_map

    conn = conn(:post, "/category/admin", %{path: "c2", name: "类别2"})
    conn = conn |> put_json_header |> put_authorization(state) |> call

    assert conn.status == 200
    c2 = conn |> resp_to_map

    [tag1, tag2, tag3] =
      1..3
      |> Enum.map(fn i ->
        conn = conn(:post, "/tag/admin", %{path: "t#{i}", name: "标签#{i}"})
        conn = conn |> put_json_header |> put_authorization(state) |> call
        assert conn.status == 200
        conn |> resp_to_map
      end)

    _created_list =
      1..15
      |> Enum.map(fn i ->
        article = %{
          path: "i-am-article-#{i}",
          title: "我是第 #{i} 篇文章"
        }

        article =
          if Integer.is_odd(i) do
            article |> Map.put(:category, c1) |> Map.put(:tags, [%{id: tag1.id}])
          else
            article |> Map.put(:category, c2) |> Map.put(:tags, [%{id: tag2.id}, %{id: tag3.id}])
          end

        conn = conn(:post, "/article/admin", article)

        conn = conn |> put_json_header |> put_authorization(state) |> call
        assert conn.status == 200
        conn |> resp_to_map
      end)

    conn = conn(:get, "/article/list?category_path=#{c1.path}")
    conn = conn |> call
    assert conn.status == 200
    list = conn |> resp_to_map
    assert length(list) == 8

    conn = conn(:get, "/article/list?tag_path=#{tag2.path}")
    conn = conn |> call
    assert conn.status == 200
    list = conn |> resp_to_map
    assert length(list) == 7

    conn = conn(:get, "/article/list")
    conn = conn |> call
    assert conn.status == 200
    list = conn |> resp_to_map
    assert length(list) == 15
    a1 = list |> Enum.at(0)
    assert a1.content == "[NotLoaded]"

    conn = conn(:put, "/article/admin/hidden/#{Enum.at(list, 0).id}")
    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    conn = conn(:delete, "/article/admin/#{Enum.at(list, 1).id}")
    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    conn = conn(:get, "/article/admin/list?res_status=1")
    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    list = conn |> resp_to_map
    assert length(list) == 13
    conn = conn(:get, "/article/list?offset=1")
    conn = conn |> call
    assert conn.status == 200
    list = conn |> resp_to_map
    assert length(list) == 12

    conn = conn(:get, "/article/admin/list")
    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    list = conn |> resp_to_map
    assert length(list) == 15
  end

  test "find article", state do
    conn = conn(:post, "/category/admin", %{path: "c1", name: "类别1"})
    conn = conn |> put_json_header |> put_authorization(state) |> call

    assert conn.status == 200
    c1 = conn |> resp_to_map

    [tag1, tag2, tag3] =
      1..3
      |> Enum.map(fn i ->
        conn = conn(:post, "/tag/admin", %{path: "t#{i}", name: "标签#{i}"})
        conn = conn |> put_json_header |> put_authorization(state) |> call
        assert conn.status == 200
        conn |> resp_to_map
      end)

    conn =
      conn(:post, "/article/admin", %{
        path: "i-am-article",
        title: "我是第一篇文章",
        category: c1,
        content: "# 前言",
        tags: [%{id: tag1.id}, %{id: tag2.id}, %{id: tag3.id}]
      })

    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    article = conn |> resp_to_map

    conn = conn(:get, "/article/query/#{article.path}") |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r != nil
    assert r.content == "<h1>前言</h1>\n"

    conn = conn(:delete, "/article/admin/#{article.id}") |> put_authorization(state) |> call
    assert conn.status == 200

    conn = conn(:get, "/article/query/#{article.path}") |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r == nil

    conn = conn(:get, "/article/admin/#{article.id}") |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r != nil
    assert r.content == "# 前言"
  end
end
