defmodule Storage.Schema.LinkTest do
  use ExUnit.Case, async: false

  alias Storage.Repo
  alias Storage.Schema.{Link}

  import Storage.Schema.Link

  require Integer

  setup do
    on_exit(fn ->
      Repo.delete_all(Link)
    end)
  end

  test "add and update link" do
    {status, link} = add(%{text: "链接1", address: "/link1", type: 1})
    assert status == :ok
    assert link.text == "链接1"
    assert link.address == "/link1"
    assert link.type == 1

    link = Map.merge(link, %{text: "修改后的链接1", address: "/link1-changed", type: 2})
    {status, link} = update(link)
    assert status == :ok
    assert link.text == "修改后的链接1"
    assert link.address == "/link1-changed"
    assert link.type == 2
  end

  test "find link list" do
    created_list =
      1..15
      |> Enum.map(fn i ->
        link = %{
          text: "第 #{i} 个链接",
          address: "/link-#{i}"
        }

        link = if Integer.is_odd(i), do: Map.put(link, :type, 1), else: Map.put(link, :type, 2)
        {status, link} = link |> add()

        assert status == :ok
        link
      end)

    {status, list} = find_list()
    assert status == :ok
    assert length(list) == 15

    {status, list} = find_list(type: 1)
    assert status == :ok
    assert length(list) == 8

    link = Map.merge(Enum.at(created_list, 0), %{res_status: -1})
    {status, _link} = update(link)
    assert status == :ok
    {status, list} = find_list(res_status: 1)
    assert status == :ok
    assert length(list) == 14

    {status, list} = find_list(res_status: 1, offset: 13)
    assert status == :ok
    assert length(list) == 1
  end
end
