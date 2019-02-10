defmodule WebServer.Routes.TweetRouter do
  @moduledoc false
  alias Storage.Schema.{Tweet}

  use WebServer.Router,
    schema: Tweet,
    include: [:admin_list, :admin_add, :admin_update, :status_manage, :top]

  get "/list" do
    [conn, paging] = fetch_paging_params(conn, 50)
    filters = paging |> specify_normal_status

    r =
      case Tweet.find_list(filters) do
        {:ok, list} ->
          list =
            list
            |> Enum.map(fn tweet ->
              {:ok, html, _} = tweet.content |> Earmark.as_html()
              %{tweet | content: html}
            end)

          {:ok, list}

        e ->
          e
      end

    conn |> resp(r)
  end

  use WebServer.RouterHelper, :default_routes
end
