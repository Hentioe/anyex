defmodule WebServer.Routes.ArticleRouter do
  @moduledoc false
  alias Storage.Schema.{Article}

  use WebServer.Router,
    schema: Article,
    include: [:admin_list, :admin_add, :admin_update, :status_manage, :top]

  get "/list" do
    [conn, paging] = fetch_paging_params(conn, 50)
    filter = paging |> specify_normal_status
    category_qname = Map.get(conn.params, "category_qname", nil)
    filter = filter |> Keyword.put(:category_qname, category_qname)

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

  get "/query/:qtext" do
    filters = [qtext: qtext] |> specify_normal_status

    r =
      case Article.find(filters) do
        {:ok, nil} ->
          {:ok, nil}

        {:ok, article} ->
          case article.content |> Earmark.as_html() do
            {:ok, html, _} ->
              {:ok, %{article | content: html}}

            e ->
              e
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
