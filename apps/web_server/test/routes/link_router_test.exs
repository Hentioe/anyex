defmodule WebServerTest.Router.LinkRouterTest do
  use WebServer.TestCase

  require Integer

  test "add and update link", state do
    conn =
      conn(:post, "/link/admin", %{
        text: "链接1",
        address: "/link-1",
        type: 1
      })

    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    link = r.data
    assert link.address == "/link-1"
    assert link.text == "链接1"

    conn =
      conn(:put, "/link/admin", %{
        id: link.id,
        address: "/link-1-updated",
        text: "更新后的链接1",
        type: 2
      })

    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    link = r.data
    assert link.address == "/link-1-updated"
    assert link.text == "更新后的链接1"
    assert link.type == 2

    conn = conn(:delete, "/link/admin/#{link.id}")

    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    link = r.data
    assert link.res_status == -1

    conn = conn(:put, "/link/admin/hidden/#{link.id}")

    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    link = r.data
    assert link.res_status == 0

    conn = conn(:put, "/link/admin/normal/#{link.id}")

    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    link = r.data
    assert link.res_status == 1
  end

  test "find link list", state do
    1..15
    |> Enum.map(fn i ->
      link = %{
        text: "第 #{i} 个链接",
        address: "/link-#{i}"
      }

      link = if Integer.is_odd(i), do: Map.put(link, :type, 1), else: Map.put(link, :type, 2)
      conn = conn(:post, "/link/admin", link)

      conn = conn |> put_json_header |> put_authorization(state) |> call
      assert conn.status == 200
      r = conn |> resp_to_map
      assert r.passed
      link = r.data
      assert link.address == "/link-#{i}"
      assert link.text == "第 #{i} 个链接"
      if Integer.is_odd(i), do: assert(link.type == 1), else: assert(link.type == 2)
    end)

    conn = conn(:get, "link/list") |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    list = r.data
    assert length(list) == 15

    conn = conn(:get, "link/list?type=1") |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    list = r.data
    assert length(list) == 8

    conn = conn(:delete, "/link/admin/#{Enum.at(list, 0).id}")

    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    link = r.data
    assert link.res_status == -1

    conn = conn(:get, "/link/list") |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    list = r.data
    assert length(list) == 14

    conn = conn(:get, "/link/admin/list") |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    list = r.data
    assert length(list) == 15

    conn = conn(:get, "/link/admin/list?type=1") |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    list = r.data
    assert length(list) == 8

    conn = conn(:get, "/link/list?type=1") |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    list = r.data
    assert length(list) == 7
  end
end
