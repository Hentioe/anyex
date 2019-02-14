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
    LinkRouter
  }

  get "/" do
    send_resp(conn, 200, "Welcome to AnyEx!")
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

  use WebServer.RouterHelper, :default_routes
end
