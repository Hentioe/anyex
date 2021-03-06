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

      plug Plug.Static,
        at: "/",
        from: {:web_server, "priv/static"}

      if Mix.env() != :test, do: plug(Plug.Logger, log: :debug)
      plug :dispatch

      def redirect(conn, url) do
        body = "<html><body>You are being <a href=\"#{url}\">redirected</a>.</body></html>"

        conn
        |> Plug.Conn.put_resp_header("location", url)
        |> Plug.Conn.send_resp(302, body)
      end
    end
  end

  def schema(schema, include) do
    quote do
      defmacro not_top(struct_data) do
        quote do
          unquote(struct_data) |> Map.merge(%{top: -1})
        end
      end

      alias WebServer.Plugs.{JSONHeaderPlug, AccessControlPlug}

      unquote(import_json_support())
      unquote(import_schema_status_macro())

      def fetch_paging_params(conn) do
        alias WebServer.Error
        import WebServer.Error

        alias WebServer.Config.Store, as: ConfigStore
        default_limit = ConfigStore.get(:web_server, :default_limit)
        max_limit = ConfigStore.get(:web_server, :max_limit)

        conn = conn |> fetch_query_params()
        offset = Map.get(conn.params, "offset", "0")
        limit = Map.get(conn.params, "limit", "#{default_limit}")

        offset =
          case Integer.parse(offset) do
            :error -> raise Error, error(:params_invalid, "'offset' is not a valid number")
            {n, _} -> n
          end

        limit =
          case Integer.parse(limit) do
            :error -> raise Error, error(:params_invalid, "'limit' is not a valid number")
            {n, _} -> n
          end

        limit = if limit > max_limit, do: max_limit, else: limit
        [conn, [offset: offset, limit: limit]]
      end

      unquote(import_includes(schema, include))
    end
  end

  def json_support() do
    quote do
      import WebServer.Router
      unquote(import_json_support())
    end
  end

  defp import_json_support do
    quote do
      use Plug.Router
      use Plug.ErrorHandler

      alias WebServer.Plugs.{JSONHeaderPlug, AccessControlPlug}
      alias WebServer.Config.Store, as: ConfigStore

      plug :match

      plug CORSPlug, origin: &__MODULE__.origins/0, methods: ["*"]

      plug Plug.Parsers,
        parsers: [Plug.Parsers.JSON],
        json_decoder: Jason

      plug JSONHeaderPlug
      plug AccessControlPlug
      if Mix.env() != :test, do: plug(Plug.Logger, log: :debug)
      plug :dispatch

      unquote(import_helper_macro())
      unquote(import_json_resp())

      def origins do
        ConfigStore.get(:web_server, :cors_origins)
      end

      def handle_errors(conn, %{kind: kind, reason: reason, stack: _stack}) do
        json_opts = JSONHeaderPlug.init(nil)
        cors_opts = CORSPlug.init(origin: &__MODULE__.origins/0, methods: ["*"])

        conn =
          conn
          |> JSONHeaderPlug.call(json_opts)
          |> CORSPlug.call(cors_opts)

        case {kind, reason} do
          {:error, %WebServer.Error{message: message, reason_type: reason_type}} ->
            resp_error(conn, %{message: message, reason_type: reason_type})

          _ ->
            resp_error(conn, %{
              kind: kind,
              reason: "internally did not successfully complete this task"
            })
        end
      end
    end
  end

  defp import_includes(schema, include) do
    quote do
      Enum.each(unquote(include), fn field ->
        case field do
          :list ->
            get "/list" do
              [conn, paging] = fetch_paging_params(var!(conn))
              filters = paging |> specify_normal_status

              conn |> var! |> resp(unquote(schema).find_list(filters))
            end

          :admin_list ->
            get "/admin/list" do
              [conn, paging] = fetch_paging_params(var!(conn))

              filters =
                paging
                |> Keyword.merge(res_status: Map.get(conn.params, "res_status"))

              conn |> var! |> resp(unquote(schema).find_list(filters))
            end

          :admin_add ->
            post "/admin" do
              data = var!(conn).body_params |> string_key_map
              result = data |> unquote(schema).add()
              conn |> var! |> resp(result)
            end

          :admin_update ->
            put "/admin" do
              data = var!(conn).body_params |> string_key_map
              result = data |> unquote(schema).update()
              conn |> var! |> resp(result)
            end

          :add ->
            post "/add" do
              data = var!(conn).body_params |> string_key_map
              result = data |> specify_hidden_status |> unquote(schema).add()
              conn |> var! |> resp(result)
            end

          :status_manage ->
            put "/admin/hidden/:id" do
              data = %{id: var!(id)}
              result = data |> specify_hidden_status |> unquote(schema).update()
              conn |> var! |> resp(result)
            end

            delete "/admin/:id" do
              data = %{id: var!(id)}
              result = data |> specify_deleted_status |> unquote(schema).update()
              conn |> var! |> resp(result)
            end

            put "/admin/normal/:id" do
              data = %{id: var!(id)}
              result = data |> specify_normal_status |> unquote(schema).update()
              conn |> var! |> resp(result)
            end

          :top ->
            post "/admin/top/:id" do
              result = unquote(schema).top(var!(id))
              conn |> var! |> resp(result)
            end

            delete "/admin/top/:id" do
              data = %{id: var!(id)}
              result = data |> not_top |> unquote(schema).update()
              conn |> var! |> resp(result)
            end

          _ ->
            raise "unknown inclusion type: #{field}"
        end
      end)
    end
  end

  defp import_json_resp() do
    quote do
      def resp_json(conn, body, status \\ 200) when is_integer(status) do
        conn
        |> send_resp(status, Jason.encode!(body))
      end

      def resp_success(conn, data \\ %{}) do
        data =
          if __MODULE__ == WebServer.Routes.CommentRouter do
            # 修正 Comment 的深度评论列表 NotLoaded 转换问题（置为 []）
            if is_list(data) do
              data |> clean_deep_comments
            else
              [data] |> clean_deep_comments |> Enum.at(0)
            end
          else
            data
          end

        resp_json(conn, data)
      end

      unquote(import_resp_error_json())

      def resp(conn, result) when is_tuple(result) do
        case result do
          {:ok, data} -> resp_success(conn, data)
          {:error, e} -> resp_error(conn, e)
        end
      end
    end
  end

  defp import_resp_error_json do
    quote do
      import WebServer.Result

      def resp_error(conn, error) when is_map(error) do
        case error do
          %{message: message, reason_type: reason_type} ->
            resp_json(conn, result(reason_type, message), 400)

          %{message: message} ->
            resp_json(conn, result(:general, message), 400)

          _ ->
            resp_json(
              conn,
              result(
                :general,
                "caught the internal cause of the error, but can't tell you~",
                error
              ),
              400
            )
        end
      end

      def resp_error(conn, error, data \\ nil) when is_binary(error) do
        resp_json(conn, result(:general, error, data), 400)
      end
    end
  end

  defp import_helper_macro() do
    quote do
      defmacro string_key_map(map) do
        quote bind_quoted: [map: map] do
          map |> AtomicMap.convert(safe: true)
        end
      end

      defmacro clean_deep_comments(list) do
        quote do
          unquote(list)
          |> Enum.map(fn c ->
            if Enum.empty?(c.comments) == 0 do
              c
            else
              comments =
                c.comments
                |> Enum.map(fn c ->
                  %{c | comments: []}
                end)

              %{c | comments: comments}
            end
          end)
        end
      end

      defmacro hidden_comments_email(list) do
        quote do
          unquote(list)
          |> Enum.map(fn c ->
            c = %{c | author_email: "[Hidden]"}

            if Enum.empty?(c.comments) == 0 do
              c
            else
              comments =
                c.comments
                |> Enum.map(fn c ->
                  c = %{c | author_email: "[Hidden]"}
                end)

              %{c | comments: comments}
            end
          end)
        end
      end
    end
  end

  defp import_schema_status_macro() do
    quote do
      @status_field :res_status
      @status_normal [{@status_field, 1}]
      @status_hidden [{@status_field, 0}]
      @status_deteled [{@status_field, -1}]

      def specify_status(filters, status) when is_list(filters) and is_list(status) do
        filters |> Keyword.merge(status)
      end

      def specify_status(struct_data, [status]) when is_map(struct_data) do
        struct_data |> Map.merge(%{@status_field => elem(status, 1)})
      end

      defmacro specify_normal_status(filters) do
        quote do
          unquote(filters) |> specify_status(@status_normal)
        end
      end

      defmacro specify_hidden_status(filters) do
        quote do
          unquote(filters) |> specify_status(@status_hidden)
        end
      end

      defmacro specify_deleted_status(filters) do
        quote do
          unquote(filters) |> specify_status(@status_deteled)
        end
      end
    end
  end
end
