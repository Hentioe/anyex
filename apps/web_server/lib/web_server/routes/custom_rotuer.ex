defmodule WebServer.Routes.CustomRouter do
  @moduledoc false
  use WebServer.Router, :json_support

  @re_res ~r/(?<res>[^\[]+)(\[(?<filters>.+)?\])?/ix

  # alias Storage.Schema.{
  #   Article,
  #   Category,
  #   Tags,
  #   Comment,
  #   Tweet,
  #   Link
  # }

  get "/" do
    # ?includes=article[offset=0,limit=5]|category[offset=0,limit=5]
    conn = conn |> fetch_query_params()
    includes = conn.params["includes"]
    includes = includes || ""

    includes = includes |> parse_includes_s
    # [article: [nil], category: [%{"offset" => "0"}, %{"limit" => "5"}], c: [nil]]
    articles =
      if Keyword.has_key?(includes, :article) do
      else
        []
      end

    categorys =
      if Keyword.has_key?(includes, :category) do
      else
        []
      end

    tags =
      if Keyword.has_key?(includes, :tag) do
      else
        []
      end

    comments =
      if Keyword.has_key?(includes, :comment) do
      else
        []
      end

    tweets =
      if Keyword.has_key?(includes, :tweet) do
      else
        []
      end

    links =
      if Keyword.has_key?(includes, :link) do
      else
        []
      end

    all_data =
      %{}
      |> put_not_empty(:articles, articles)
      |> put_not_empty(:categorys, categorys)
      |> put_not_empty(:tags, tags)
      |> put_not_empty(:comments, comments)
      |> put_not_empty(:tweets, tweets)
      |> put_not_empty(:links, links)

    conn |> resp_success(all_data)
  end

  defp parse_includes_s(includes) do
    parse_f = fn filter_s ->
      kv_s = filter_s |> String.split("=")
      if length(kv_s) > 1, do: Map.put(%{}, Enum.at(kv_s, 0), Enum.at(kv_s, 1)), else: nil
    end

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

      filters =
        filters_s
        |> String.split(",")
        |> Enum.map(parse_f)

      {res, filters}
    end)
  end

  def put_not_empty(map, key, data) when is_map(map) and is_atom(key) do
    empty? = (is_list(data) && Enum.empty?(data)) || data == nil
    if empty?, do: map, else: Map.put(map, key, data)
  end

  use WebServer.RouterHelper, :default_routes
end
