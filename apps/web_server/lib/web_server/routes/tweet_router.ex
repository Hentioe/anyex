defmodule WebServer.Routes.TweetRouter do
  @moduledoc false
  alias Storage.Schema.{Tweet}
  alias WebServer.Configure.Store, as: ConfigStore

  use WebServer.Router,
    schema: Tweet,
    include: [:admin_list, :admin_add, :admin_update, :status_manage, :top]

  get "/list" do
    [conn, paging] = conn |> fetch_paging_params()
    filters = paging |> specify_normal_status

    r =
      case Tweet.find_list(filters) do
        {:ok, list} ->
          markdown_support = ConfigStore.get(:web_server, :tweet_markdown_support) || false

          markdown_support? =
            if is_atom(markdown_support),
              do: markdown_support,
              else: String.to_existing_atom(markdown_support)

          list =
            list
            |> Enum.map(fn tweet ->
              if markdown_support? do
                {:ok, html, _} = tweet.content |> Earmark.as_html()
                %{tweet | content: html}
              else
                tweet
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
