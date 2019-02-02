defmodule Storage.Repo.ArticleTest do
  use ExUnit.Case

  alias Storage.Repo
  alias Storage.Repo.{Article, Category}

  import Storage.Repo.Article

  setup_all do
    on_exit(fn ->
      Repo.delete_all(Article)
      Repo.delete_all(Category)
    end)
  end

  test "add article" do
    {status, category} = Category.add(%{qname: "c1", name: "类别1"})
    assert status == :ok

    {status, article} = add(%{qtext: "first-article", title: "第一篇文章", category_id: category.id})

    assert status == :ok
    assert article.category_id == category.id
  end
end
