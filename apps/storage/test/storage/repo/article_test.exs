defmodule Storage.Repo.ArticleTest do
  use ExUnit.Case

  alias Storage.Repo
  alias Storage.Repo.{Article, Category, Tag}

  import Storage.Repo.Article

  setup do
    on_exit(fn ->
      Repo.delete_from!(:articles_tags)
      Repo.delete_all(Article)
      Repo.delete_all(Tag)
      Repo.delete_all(Category)
    end)
  end

  test "add and update article" do
    {status, category} = Category.add(%{qname: "c1", name: "类别1"})
    assert status == :ok

    {status, tag1} = Tag.add(%{qname: "t1", name: "标签1"})
    assert status == :ok
    {status, tag2} = Tag.add(%{qname: "t2", name: "标签2"})
    assert status == :ok

    {status, article} =
      add(%{qtext: "first-article", title: "第一篇文章", category_id: category.id, tags: [tag1, tag2]})

    assert status == :ok
    assert article.category_id == category.id
    assert length(article.tags) == 2

    article = Map.merge(article, %{title: "修改后的文章", tags: [tag1]})
    {status, article} = update(article)
    assert status == :ok
    assert article.category_id == category.id
    assert length(article.tags) == 1
    assert Enum.at(article.tags, 0).id == tag1.id
  end
end
