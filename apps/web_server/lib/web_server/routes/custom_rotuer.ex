defmodule WebServer.Routes.CustomRouter do
  @moduledoc false
  use WebServer.Router, :json_support

  # alias Storage.Schema.{
  #   ArticleRouter,
  #   CategoryRouter,
  #   TagsRouter,
  #   CommentRouter,
  #   TweetRouter,
  #   LinkRouter
  # }

  get "/" do
    conn = conn |> fetch_query_params()
    includes = conn.params["includes"]
    includes = includes || ""

    includes
    |> String.split(",")
    |> Enum.map(fn include ->
      try do
        {:ok, String.to_existing_atom(include)}
      rescue
        _e in _ -> {:error, "unknown resource type: #{include}"}
      end
    end)
    |> Enum.filter(&(elem(&1, 0) == :ok))
    |> Enum.map(&elem(&1, 1))

    conn |> resp_success([])
  end

  use WebServer.RouterHelper, :default_routes
end
