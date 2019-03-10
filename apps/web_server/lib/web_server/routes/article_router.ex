defmodule WebServer.Routes.ArticleRouter do
  @moduledoc false
  alias Storage.Schema.{Article}
  alias WebServer.Config.Store, as: ConfigStore
  alias WebServer.Error

  import WebServer.{Common, Error}

  use WebServer.Router,
    schema: Article,
    include: [:admin_list, :admin_update, :status_manage, :top]

  post "/admin" do
    data = conn.body_params |> string_key_map

    path = get_path(data.path, data.title)

    result = data |> Map.put(:path, path) |> Article.add()
    conn |> resp(result)
  end

  get "/list" do
    [conn, paging] = conn |> fetch_paging_params()
    filter = paging |> specify_normal_status
    category_path = conn.params |> Map.get("category_path", nil)
    tag_path = conn.params |> Map.get("tag_path", nil)

    filter =
      filter |> Keyword.put(:category_path, category_path) |> Keyword.put(:tag_path, tag_path)

    r =
      case filter |> Article.find_list() do
        {:ok, list} ->
          list =
            list
            |> Enum.map(fn article ->
              %{article | content: "[NotLoaded]"}
            end)

          {:ok, list}

        e ->
          e
      end

    conn |> resp(r)
  end

  get "/" do
    conn = conn |> fetch_query_params()
    path = conn.params |> Map.get("path")
    unless path, do: raise(Error, error(:params_deficiency, "Path parameter not found"))
    filters = [path: path] |> specify_normal_status

    r =
      case Article.find(filters) do
        {:ok, nil} ->
          raise(Error, error(:not_found, "This article is missing..."))

        {:ok, article} ->
          markdown_support? = ConfigStore.exists(:web_server, :markdown_enables, :article)

          if markdown_support? do
            case article.content |> Earmark.as_html() do
              {:ok, html, _} ->
                {:ok, %{article | content: html}}

              e ->
                e
            end
          else
            {:ok, article}
          end

        e ->
          e
      end

    conn |> resp(r)
  end

  get "/admin/:id" do
    r = Article.find(id: id)
    conn |> resp(r)
  end

  use WebServer.RouterHelper, :default_routes
end
