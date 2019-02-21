defmodule WebServer.Routes.CustomRouter do
  @moduledoc false
  use WebServer.Router, :json_support
  use Plug.Test

  alias WebServer.Routes.{
    ArticleRouter,
    CategoryRouter,
    TagRouter,
    CommentRouter,
    TweetRouter,
    LinkRouter
  }

  get "/" do
    # ?includes=article[offset=0,limit=5]|category[offset=0,limit=5]
    conn = conn |> fetch_query_params()
    includes = conn.params["includes"]
    includes = includes || ""

    includes = includes |> parse_includes_s
    # [article: "offset=0&limit=5", category: "offset=0&limit=5"]
    articles = includes |> dispatch_to(:article, :get, "/list", ArticleRouter)
    categories = includes |> dispatch_to(:category, :get, "/list", CategoryRouter)
    tags = includes |> dispatch_to(:tag, :get, "/list", TagRouter)
    comments = includes |> dispatch_to(:comment, :get, "/list", CommentRouter)
    tweets = includes |> dispatch_to(:tweet, :get, "/list", TweetRouter)
    links = includes |> dispatch_to(:link, :get, "/list", LinkRouter)

    all_data =
      %{}
      |> put_data_set(:articles, articles)
      |> put_data_set(:categories, categories)
      |> put_data_set(:tags, tags)
      |> put_data_set(:comments, comments)
      |> put_data_set(:tweets, tweets)
      |> put_data_set(:links, links)

    conn |> resp_success(all_data)
  end

  @re_res ~r/(?<res>[^\[]+)(\[(?<filters>.+)?\])?/ix
  defp parse_includes_s(includes) do
    includes
    |> String.split("|")
    |> Enum.map(&String.trim(&1))
    |> Enum.map(&Regex.replace(~r/\s+/, &1, ""))
    |> Enum.map(fn include ->
      Regex.named_captures(@re_res, include) || %{"res" => include}
    end)
    |> Enum.map(fn res_filters ->
      # %{"filters" => "offset=0,limit=5", "res" => "article"}
      try do
        %{"filters" => filters, "res" => res} = res_filters
        {:ok, {String.to_existing_atom(res), filters}}
      rescue
        _e in _ -> {:error, "unknown resource type: #{Map.get(res_filters, "res")}"}
      end
    end)
    |> Enum.filter(&(elem(&1, 0) == :ok))
    |> Enum.map(&elem(&1, 1))
    |> Enum.map(fn {res, filters_s} ->
      # {:category, "offset=0,limit=5"}
      filters = filters_s |> String.replace(",", "&")

      {res, filters}
    end)
  end

  defp dispatch_to(includes, key, method, path, router) do
    if Keyword.has_key?(includes, key) do
      conn = conn(method, "#{path}?#{includes[key]}")
      resp = conn |> router.call(router.init([]))

      if resp.status == 200 do
        body = Jason.decode!(resp.resp_body)

        {:ok, body}
      else
        {:error, "wrong response"}
      end
    else
      {:error, "[NotLoaded]"}
    end
  end

  defp put_data_set(map, key, resp) when is_map(map) and is_atom(key) do
    case resp do
      {:ok, data} ->
        Map.put(map, key, %{status: "[Loaded]", data: data})

      {:error, reason} ->
        Map.put(map, key, %{status: reason, data: []})
    end
  end

  use WebServer.RouterHelper, :default_routes
end
