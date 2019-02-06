defmodule WebServer.Routes.CategoryRouter do
  @moduledoc false
  alias Storage.Schema.{Category}

  use WebServer.Router,
    schema: Category,
    include: [:list, :admin_list, :admin_add, :admin_update, :status_manage, :top]

  use WebServer.RouterHelper, :default_routes
end
