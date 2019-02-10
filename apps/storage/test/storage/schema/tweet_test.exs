defmodule Storage.Schema.TweetTest do
  use ExUnit.Case, async: false

  alias Storage.Repo
  alias Storage.Schema.{Tweet}

  import Storage.Schema.Tweet

  setup do
    on_exit(fn ->
      Repo.delete_all(Tweet)
    end)
  end

  test "add and update tweet" do
    {status, tweet} = add(%{theme: "red", content: "推文1"})
    assert status == :ok
    assert tweet.theme == "red"
    assert tweet.content == "推文1"

    tweet = Map.merge(tweet, %{theme: "blue", content: "修改后的推文1"})
    {status, tweet} = update(tweet)
    assert status == :ok
    assert tweet.theme == "blue"
    assert tweet.content == "修改后的推文1"
  end

  test "find tweet list" do
    created_list =
      1..15
      |> Enum.map(fn i ->
        {status, tweet} =
          add(%{
            theme: "#00000#{i}",
            content: "第 #{i} 个推文"
          })

        assert status == :ok
        tweet
      end)

    {status, list} = find_list()
    assert status == :ok
    assert length(list) == 15

    tweet = Map.merge(Enum.at(created_list, 0), %{res_status: -1})
    {status, _tweet} = update(tweet)
    assert status == :ok
    {status, list} = find_list(res_status: 1)
    assert status == :ok
    assert length(list) == 14

    {status, list} = find_list(res_status: 1, offset: 13)
    assert status == :ok
    assert length(list) == 1
  end
end
