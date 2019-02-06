defmodule WebServer.Routes.ArticleRouter do
  @moduledoc false
  alias Storage.Schema.{Article}

  use WebServer.Router, schema: Article

  post "/admin" do
    article = conn.body_params
    result = article |> Article.add()
    conn |> resp(result)
  end

  use WebServer.RouterHelper, :default_routes
end
