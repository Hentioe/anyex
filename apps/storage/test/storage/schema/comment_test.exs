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
        author_email: "xiaoming@bluerain.io",
        content: "评论1",
        article_id: article.id
      })

    assert status == :ok

    comment = Map.merge(comment, %{content: "我是修改后的评论1"})
    {status, comment} = update(comment)
    assert status == :ok
    assert comment.content == "我是修改后的评论1"

    {status, _sub_comment} =
      add(%{
        author_nickname: "李小狼",
        author_email: "xiaolang@bluerain.io",
        content: "@王小明 回复你的评论2",
        article_id: article.id,
        parent_id: comment.id
      })

    assert status == :ok
  end

  test "find comment list" do
    {status, category} = Category.add(%{qname: "c1", name: "类别1"})
    assert status == :ok

    {status, article} =
      Article.add(%{qtext: "first-article", title: "第一篇文章", category_id: category.id})

    assert status == :ok
    assert article.category_id == category.id

    {status, comment} =
      add(%{
        author_nickname: "王小明",
        author_email: "xiaoming@bluerain.io",
        content: "评论1",
        article_id: article.id
      })

    assert status == :ok

    {status, sub_comment_xiaolang} =
      add(%{
        author_nickname: "李小狼",
        author_email: "xiaolang@bluerain.io",
        content: "@王小明 回复你的评论2",
        article_id: article.id,
        parent_id: comment.id
      })

    assert status == :ok

    {status, sub_comment_xiaoming} =
      add(%{
        author_nickname: "王小明",
        author_email: "xiaoming@bluerain.io",
        content: "@李小狼 感谢你的回复3",
        article_id: article.id,
        parent_id: comment.id
      })

    assert status == :ok

    {status, list} = find_list()

    assert status == :ok
    assert length(list) == 3
    {status, list} = find_list(article_id: article.id)
    assert status == :ok
    assert length(list) == 1

    assert Enum.at(Enum.at(list, 0).comments, 0).id == sub_comment_xiaoming.id

    {status, _top_comment} = top(sub_comment_xiaolang.id)
    assert status == :ok

    {status, list} = find_list(article_id: article.id)
    assert status == :ok
    assert length(list) == 1

    assert Enum.at(Enum.at(list, 0).comments, 0).id == sub_comment_xiaolang.id
  end
end
