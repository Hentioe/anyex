defmodule WebServer.Routes.ArticleRouter do
  @moduledoc false
  alias Storage.Schema.{Article}
  alias WebServer.Config.Store, as: ConfigStore

  use WebServer.Router,
    schema: Article,
    include: [:admin_list, :admin_update, :status_manage, :top]

  post "/admin" do
    data = conn.body_params |> string_key_map

    qtext =
      case ConfigStore.get(:web_server, :path_strategy) do
        :raw -> data.qtext
        :uuid -> UUID.uuid4()
        _ -> nil
      end

    result = data |> Map.put(:qtext, qtext) |> Article.add()
    conn |> resp(result)
  end

  get "/list" do
    [conn, paging] = conn |> fetch_paging_params()
    filter = paging |> specify_normal_status
    category_qname = conn.params |> Map.get("category_qname", nil)
    tag_qname = conn.params |> Map.get("tag_qname", nil)

    filter =
      filter |> Keyword.put(:category_qname, category_qname) |> Keyword.put(:tag_qname, tag_qname)

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
