defmodule WebServer.Routes.CustomRouter do
  @moduledoc false
  use WebServer.Router, :json_support

  get "/" do
    conn |> resp_success([])
  end

  use WebServer.RouterHelper, :default_routes
end
