defmodule WebServer.Routes.CommentRouter do
  @moduledoc false
  alias Storage.Schema.{Comment}

  use WebServer.Router,
    schema: Comment,
    include: [:admin_update, :status_manage, :top]

  get "/list" do
    [conn, paging] = conn |> fetch_paging_params()
    filters = paging |> specify_normal_status
    article_id = Map.get(conn.params, "article_id")
    filters = filters |> Keyword.merge(article_id: article_id)

    r =
      case Comment.find_list(filters) do
        {:ok, list} ->
          list =
            if article_id do
              list
            else
              list |> empty_subs()
            end

          list = list |> hidden_comments_email

          {:ok, list}

        e ->
          e
      end

    conn |> resp(r)
  end

  def empty_subs(list) when is_list(list) do
    list
    |> Enum.map(fn c ->
      %{c | comments: []}
    end)
  end

  post "/add" do
    data =
      conn.body_params
      |> string_key_map
      |> specify_normal_status
      |> Map.put(:owner, false)

    r = data |> Comment.add()
    conn |> resp(r)
  end

  post "/admin" do
    data =
      conn.body_params
      |> string_key_map
      |> specify_normal_status
      |> Map.put(:owner, true)

    r = data |> Comment.add()
    conn |> resp(r)
  end

  get "/admin/list" do
    [conn, paging] = conn |> fetch_paging_params()
    article_id = Map.get(conn.params, "article_id")

    filters =
      paging
      |> Keyword.merge(article_id: article_id)
      |> Keyword.merge(res_status: Map.get(conn.params, "res_status"))

    r =
      case Comment.find_list(filters) do
        {:ok, list} ->
          list =
            if article_id do
              list
            else
              list |> empty_subs()
            end

          {:ok, list}

        e ->
          e
      end

    conn |> resp(r)
  end

  use WebServer.RouterHelper, :default_routes
end
