defmodule WebServer.Router do
  @moduledoc false
  defmacro __using__(schema: schema) do
    apply(__MODULE__, :schema, [schema, []])
  end

  defmacro __using__(schema: schema, include: include) do
    apply(__MODULE__, :schema, [schema, include])
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def default do
    quote do
      use Plug.Router

      plug :match
      plug :dispatch
    end
  end

  def schema(schema, include) do
    quote do
      use Plug.Router

      alias WebServer.Plugs.{JSONHeaderPlug, JwtAuthPlug}

      plug :match

      plug Plug.Parsers,
        parsers: [Plug.Parsers.JSON],
        json_decoder: Jason

      plug JSONHeaderPlug

      if Mix.env() == :prod, do: plug(JwtAuthPlug)

      plug :dispatch

      def resp_json(conn, body, status \\ 200) when is_integer(status) do
        conn
        |> send_resp(status, Jason.encode!(body))
      end

      def resp_error(conn, error) when is_map(error) do
        message = Map.get(error, :message)

        if message == nil do
          resp_json(conn, %{passed: false, message: "EXPECTED", data: error})
        else
          resp_json(conn, %{passed: false, message: message, data: nil})
        end
      end

      def resp_error(conn, error, data \\ %{}) when is_binary(error) do
        resp_json(conn, %{passed: false, message: error, data: data})
      end

      def resp_success(conn, data \\ %{}) do
        resp_json(conn, %{passed: true, message: "SUCCESS", data: data})
      end

      def resp(conn, result) when is_tuple(result) do
        case result do
          {:ok, data} -> resp_success(conn, data)
          {:error, e} -> resp_error(conn, e)
        end
      end

      def fetch_paging_params(conn, limit) do
        conn = conn |> fetch_query_params()
        offset = Map.get(conn.params, "offset", 0)
        limit = Map.get(conn.params, "limit", limit)
        [conn, [offset: offset, limit: limit]]
      end

      Enum.each(unquote(include), fn field ->
        case field do
          :list ->
            get "/list" do
              [conn, paging] = fetch_paging_params(var!(conn), 50)
              filters = Keyword.merge(paging, res_status: 0)

              conn |> var! |> resp(unquote(schema).find_list(filters))
            end

          :admin_list ->
            get "admin/list" do
              [conn, paging] = fetch_paging_params(var!(conn), 50)
              filters = paging

              conn |> var! |> resp(unquote(schema).find_list(filters))
            end

          :admin_add ->
            post "/admin" do
              data = var!(conn).body_params
              result = data |> unquote(schema).add()
              conn |> var! |> resp(result)
            end

          :admin_update ->
            put "/admin" do
              data = var!(conn).body_params
              result = data |> unquote(schema).update()
              conn |> var! |> resp(result)
            end

          :add ->
            post "/add" do
              data = var!(conn).body_params
              result = data |> unquote(schema).add()
              conn |> var! |> resp(result)
            end

          :status_manage ->
            put "/admin/hidden/:id" do
              result = unquote(schema).update(%{id: var!(id), res_status: 0})
              conn |> var! |> resp(result)
            end

            delete "/admin/:id" do
              result = unquote(schema).update(%{id: var!(id), res_status: -1})
              conn |> var! |> resp(result)
            end

            put "/admin/normal/:id" do
              result = unquote(schema).update(%{id: var!(id), res_status: 1})
              conn |> var! |> resp(result)
            end

          :top ->
            post "/admin/top/:id" do
              result = unquote(schema).top(var!(id))
              conn |> var! |> resp(result)
            end

            delete "/admin/top/:id" do
              result = unquote(schema).update(%{id: var!(id), top: -1})
              conn |> var! |> resp(result)
            end

          _ ->
            raise "unknown inclusion type: #{field}"
        end
      end)
    end
  end
end
