defmodule WebServer.Routes.ArticleRouter do
  @moduledoc false
  alias Storage.Schema.{Article}

  use WebServer.Router,
    schema: Article,
    include: [:list, :admin_list, :admin_add, :admin_update, :status_manage, :top]

  get "/query/:qtext" do
    filters = [qtext: qtext] |> specify_normal_status
    r = Article.find(filters)
    conn |> resp(r)
  end

  get "/admin/:id" do
    r = Article.find(id: id)
    conn |> resp(r)
  end

  use WebServer.RouterHelper, :default_routes
end
