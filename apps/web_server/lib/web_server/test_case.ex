defmodule WebServer.TestCase do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use ExUnit.Case, async: false
      use Plug.Test

      alias Storage.Repo
      alias Storage.Schema.{Article, Category, Tag, Comment, Tweet, Link}
      alias WebServer.Routes
      alias WebServer.Configure.Store, as: ConfigStore

      @opts Routes.init([])

      setup do
        on_exit(fn ->
          Repo.delete_from!(:articles_tags)
          Repo.delete_all(Comment)
          Repo.delete_all(Tag)
          Repo.delete_all(Article)
          Repo.delete_all(Category)
          Repo.delete_all(Tweet)
          Repo.delete_all(Link)
        end)

        username = ConfigStore.get(:web_server, :username)
        password = ConfigStore.get(:web_server, :password)

        conn = conn(:post, "token/gen", %{username: username, password: password})
        conn = conn |> put_req_header("content-type", "application/json") |> Routes.call(@opts)
        unless conn.status == 200, do: raise("request token failed")
        r = conn.resp_body |> Jason.decode!(keys: :atoms)
        unless r.passed, do: raise(r.message)
        {:ok, token: r.data}
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

      defmacro put_authorization(conn, state) do
        quote do
          put_req_header(unquote(conn), "authorization", unquote(state).token)
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
