defmodule WebServer.Test.Case do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use ExUnit.Case, async: false
      use Plug.Test

      alias Storage.Repo
      alias Storage.Schema.{Article, Category, Tag}
      alias WebServer.Routes

      @opts Routes.init([])

      setup do
        on_exit(fn ->
          Repo.delete_from!(:articles_tags)
          Repo.delete_all(Tag)
          Repo.delete_all(Article)
          Repo.delete_all(Category)
        end)

        {:ok, token: "token"}
      end

      defmacro call(conn) do
        quote do
          Routes.call(unquote(conn), @opts)
        end
      end

      defmacro put_json_header(conn) do
        quote do
          put_req_header(unquote(conn), "content-type", "application/json")
        end
      end

      defmacro resp_to_map(conn) do
        quote bind_quoted: [conn: conn] do
          conn.resp_body |> Jason.decode!(keys: :atoms)
        end
      end
    end
  end
end
