defmodule WebServer.Routes.CommentRouter do
  @moduledoc false
  alias Storage.Schema.{Comment}

  use WebServer.Router,
    schema: Comment,
    include: [:admin_update, :status_manage, :top]

  post "/add" do
    data =
      conn.body_params
      |> string_key_map
      |> specify_normal_status
      |> Map.put(:owner, false)

    r = data |> Comment.add()
    conn |> resp(r)
  end

  post "/admin/add" do
    data =
      conn.body_params
      |> string_key_map
      |> specify_normal_status
      |> Map.put(:owner, true)

    r = data |> Comment.add()
    conn |> resp(r)
  end

  get "/from_article/:id" do
    [conn, paging] = fetch_paging_params(conn, 50)
    filters = paging |> specify_normal_status |> Keyword.merge(article_id: id)

    r =
      case Comment.find_list(filters) do
        {:ok, list} ->
          list =
            list
            |> Enum.map(fn c ->
              if Enum.empty?(c.comments) == 0 do
                c
              else
                comments =
                  c.comments
                  |> Enum.map(fn c ->
                    %{c | comments: []}
                  end)

                %{c | comments: comments}
              end
            end)

          {:ok, list}

        e ->
          e
      end

    conn |> resp(r)
  end

  use WebServer.RouterHelper, :default_routes
end
