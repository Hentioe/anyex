defmodule Storage.Schema do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Storage.Schema
      @behaviour Storage.Schema

      @status_field :res_status

      def add(schema, data) when is_map(data) do
        changeset = schema |> changeset(data)

        if changeset.valid? do
          try do
            Storage.Repo.insert(changeset)
          rescue
            e in _ -> {:error, e}
          end
        else
          {:error, traverse_errors(changeset)}
        end
      end

      def update(schema, data) when is_map(data) do
        data = data |> Map.drop([:__meta__, :__struct__])

        case schema do
          nil ->
            {:error, "do not find id: `#{data.id}` of resource"}

          article ->
            changeset = article |> changeset(data)

            if changeset.valid? do
              try do
                Storage.Repo.update(changeset)
              rescue
                e in _ -> {:error, e}
              end
            else
              {:error, traverse_errors(changeset)}
            end
        end
      end

      def query_list(query) do
        try do
          list = query |> Storage.Repo.all()
          {:ok, list}
        rescue
          e in _ -> {:error, e}
        end
      end

      def top(struct, id) when is_integer(id) do
        resource = Storage.Repo.get(struct, id)

        case resource do
          nil -> {:error, "do not find id: `#{id}` of resource"}
          r -> r |> Map.merge(%{top: :os.system_time(:milli_seconds)}) |> update()
        end
      end

      defoverridable add: 2
      defoverridable query_list: 1
      defoverridable top: 2
    end
  end

  defmacro common_fields(:v001) do
    quote bind_quoted: binding() do
      timestamps(type: :utc_datetime_usec)
      field :res_status, :integer, default: 0
    end
  end

  defmacro guaranteed_id(data, do: block) do
    quote do
      case unquote(data).id do
        nil -> {:error, "resource id cannot be empty"}
        _ -> unquote(block)
      end
    end
  end

  def traverse_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  @callback changeset(t :: term, data :: Map.t()) :: term
end
