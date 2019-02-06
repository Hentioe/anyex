defmodule WebServer.Routes do
  @moduledoc false
  use WebServer.Router, :default

  alias WebServer.Routes.{ArticleRouter, CategoryRouter, TagRouter, TokenRouter}

  get "/" do
    send_resp(conn, 200, "Welcome to AnyEx!")
  end

  forward "/article", to: ArticleRouter
  forward "/category", to: CategoryRouter
  forward "/tag", to: TagRouter
  forward "/token", to: TokenRouter

  use WebServer.RouterHelper, :default_routes
end
