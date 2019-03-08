defmodule WebServerTest.Router.TagRouterTest do
  use WebServer.TestCase

  test "add and update tag", state do
    conn =
      conn(:post, "/tag/admin", %{
        path: "tag-1",
        name: "标签1"
      })

    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    tag = conn |> resp_to_map
    assert tag.path == "tag-1"
    assert tag.name == "标签1"

    conn =
      conn(:put, "/tag/admin", %{
        id: tag.id,
        path: "tag-1-updated",
        name: "更新后的标签1"
      })

    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    tag = conn |> resp_to_map
    assert tag.path == "tag-1-updated"
    assert tag.name == "更新后的标签1"

    conn = conn(:delete, "/tag/admin/#{tag.id}")

    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    tag = conn |> resp_to_map
    assert tag.res_status == -1

    conn = conn(:put, "/tag/admin/hidden/#{tag.id}")

    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    tag = conn |> resp_to_map
    assert tag.res_status == 0

    conn = conn(:put, "/tag/admin/normal/#{tag.id}")

    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    tag = conn |> resp_to_map
    assert tag.res_status == 1
  end

  test "find tag list", state do
    1..15
    |> Enum.map(fn i ->
      conn =
        conn(:post, "/tag/admin", %{
          path: "tag-#{i}",
          name: "标签#{i}"
        })

      conn = conn |> put_json_header |> put_authorization(state) |> call
      assert conn.status == 200
      tag = conn |> resp_to_map
      assert tag.path == "tag-#{i}"
      assert tag.name == "标签#{i}"
    end)

    conn = conn(:get, "tag/list") |> call
    assert conn.status == 200
    list = conn |> resp_to_map
    assert length(list) == 15

    conn = conn(:delete, "/tag/admin/#{Enum.at(list, 0).id}")

    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    tag = conn |> resp_to_map
    assert tag.res_status == -1

    conn = conn(:get, "/tag/list") |> call
    assert conn.status == 200
    list = conn |> resp_to_map
    assert length(list) == 14

    conn = conn(:get, "/tag/admin/list") |> put_authorization(state) |> call
    assert conn.status == 200
    list = conn |> resp_to_map
    assert length(list) == 15
  end
end
