defmodule WebServer.Routes.TweetRouter do
  @moduledoc false
  alias Storage.Schema.{Tweet}

  use WebServer.Router,
    schema: Tweet,
    include: [:list, :admin_list, :admin_add, :admin_update, :status_manage, :top]

  use WebServer.RouterHelper, :default_routes
end
