defmodule WebServer.Routes do
  @moduledoc false

  use WebServer.Router, :default

  alias WebServer.Routes.{
    ArticleRouter,
    CategoryRouter,
    TagRouter,
    TokenRouter,
    CommentRouter,
    TweetRouter,
    LinkRouter,
    CustomRouter
  }

  get "/" do
    conn |> redirect("/index.html")
  end

  get "/ping" do
    send_resp(conn, 200, "pong")
  end

  get "/version" do
    {:ok, vsn} = :application.get_key(:web_server, :vsn)

    send_resp(conn, 200, List.to_string(vsn))
  end

  forward "/article", to: ArticleRouter
  forward "/category", to: CategoryRouter
  forward "/tag", to: TagRouter
  forward "/token", to: TokenRouter
  forward "/comment", to: CommentRouter
  forward "/tweet", to: TweetRouter
  forward "/link", to: LinkRouter
  forward "/custom", to: CustomRouter

  use WebServer.RouterHelper, :default_routes
end
