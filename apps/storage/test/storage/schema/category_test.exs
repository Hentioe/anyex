defmodule Storage.Schema.CategoryTest do
  use ExUnit.Case

  alias Storage.Repo
  alias Storage.Schema.{Category}

  import Storage.Schema.Category

  setup do
    on_exit(fn ->
      Repo.delete_all(Category)
    end)
  end

  test "add and update category" do
    {status, category} = add(%{qname: "c1", name: "类别1"})
    assert status == :ok

    category = Map.merge(category, %{qname: "c1-changed", name: "修改后的类别名称"})
    {status, category} = update(category)
    assert status == :ok
    assert category.qname == "c1-changed"
    assert category.name == "修改后的类别名称"
  end

  test "find category list" do
    created_list =
      1..15
      |> Enum.map(fn i ->
        {status, category} =
          add(%{
            qname: "first-category-#{i}",
            name: "第 #{i} 个类别"
          })

        assert status == :ok
        category
      end)

    {status, list} = find_list()
    assert status == :ok
    assert length(list) == 15

    category = Map.merge(Enum.at(created_list, 0), %{res_status: -1})
    {status, _category} = update(category)
    assert status == :ok
    {status, list} = find_list()
    assert status == :ok
    assert length(list) == 14

    {status, list} = find_list(offset: 13)
    assert status == :ok
    assert length(list) == 1
  end
end
