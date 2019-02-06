defmodule WebServer.Routes.ArticleRouter do
  @moduledoc false
  use WebServer.Router, :schema

  alias Storage.Schema.{Article}

  get "/list" do
    [conn, paging] = fetch_paging_params(conn, 50)
    filters = Keyword.merge(paging, res_status: 0)

    case Article.find_list(filters) do
      {:ok, list} -> resp_success(conn, list)
      {:error, e} -> resp_error(conn, e)
    end
  end

  get "admin/list" do
    [conn, paging] = fetch_paging_params(conn, 50)
    filters = paging

    case Article.find_list(filters) do
      {:ok, list} -> resp_json(conn, list)
      {:error, e} -> resp_error(conn, e)
    end
  end

  use WebServer.RouterHelper, :default_routes
end
