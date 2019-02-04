defmodule Storage.Schema.CommentTest do
  use ExUnit.Case, async: false

  alias Storage.Repo
  alias Storage.Schema.{Comment, Category, Article}

  import Storage.Schema.Comment

  setup do
    on_exit(fn ->
      Repo.delete_all(Comment)
      Repo.delete_all(Article)
      Repo.delete_all(Category)
    end)
  end

  test "add and update comment" do
    {status, category} = Category.add(%{qname: "c1", name: "类别1"})
    assert status == :ok

    {status, article} =
      Article.add(%{qtext: "first-article", title: "第一篇文章", category_id: category.id})

    assert status == :ok
    assert article.category_id == category.id

    {status, comment} =
      add(%{
        author_nickname: "王小明",
        author_email: "me@bluerain.io",
        content: "评论1",
        article_id: article.id
      })

    assert status == :ok

    comment = Map.merge(comment, %{content: "我是修改后的评论1"})
    {status, comment} = update(comment)
    assert status == :ok
    assert comment.content == "我是修改后的评论1"
  end
end
