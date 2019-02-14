defmodule WebServer.Routes.LinkRouter do
  @moduledoc false
  alias Storage.Schema.{Link}

  use WebServer.Router,
    schema: Link,
    include: [:admin_add, :admin_update, :status_manage, :top]

  get "/list" do
    [conn, paging] = conn |> fetch_paging_params()
    type = conn.params["type"]
    filters = paging |> specify_normal_status
    filters = if type, do: filters |> Keyword.put(:type, type), else: filters

    conn |> resp(Link.find_list(filters))
  end

  get "/admin/list" do
    [conn, filters] = conn |> fetch_paging_params()
    type = conn.params["type"]
    filters = if type, do: filters |> Keyword.put(:type, type), else: filters

    conn |> resp(Link.find_list(filters))
  end

  use WebServer.RouterHelper, :default_routes
end
