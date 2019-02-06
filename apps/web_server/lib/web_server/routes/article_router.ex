defmodule WebServer.Routes.ArticleRouter do
  @moduledoc false
  alias Storage.Schema.{Article}

  use WebServer.Router, schema: Article, include: [:top]

  use WebServer.RouterHelper, :default_routes
end
