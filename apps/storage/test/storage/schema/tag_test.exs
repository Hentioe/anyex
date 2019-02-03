defmodule Storage.Schema.TagTest do
  use ExUnit.Case

  alias Storage.Repo
  alias Storage.Schema.{Tag}

  import Storage.Schema.Tag

  setup do
    on_exit(fn ->
      Repo.delete_all(Tag)
    end)
  end

  test "add and update tag" do
    {status, tag} = add(%{qname: "t1", name: "标签1"})
    assert status == :ok

    tag = Map.merge(tag, %{qname: "t1-changed", name: "修改后的标签名称"})
    {status, tag} = update(tag)
    assert status == :ok
    assert tag.qname == "t1-changed"
    assert tag.name == "修改后的标签名称"
  end

  test "find tag list" do
    created_list =
      1..15
      |> Enum.map(fn i ->
        {status, tag} =
          add(%{
            qname: "first-tag-#{i}",
            name: "第 #{i} 个标签"
          })

        assert status == :ok
        tag
      end)

    {status, list} = find_list()
    assert status == :ok
    assert length(list) == 15

    tag = Map.merge(Enum.at(created_list, 0), %{res_status: -1})
    {status, _tag} = update(tag)
    assert status == :ok
    {status, list} = find_list()
    assert status == :ok
    assert length(list) == 14

    {status, list} = find_list(offset: 13)
    assert status == :ok
    assert length(list) == 1
  end
end
