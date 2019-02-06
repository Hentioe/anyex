defmodule WebServer.Routes.TagRouter do
  @moduledoc false
  alias Storage.Schema.{Tag}

  use WebServer.Router,
    schema: Tag,
    include: [:list, :admin_list, :admin_add, :admin_update, :status_manage, :top]

  use WebServer.RouterHelper, :default_routes
end
