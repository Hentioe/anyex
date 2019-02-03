defmodule Storage.Schema do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Storage.Schema
      @behaviour Storage.Schema

      @status_field :res_status

      def add(schema, params) when is_map(params) do
        changeset = schema |> changeset(params)

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

      def update(schema, params) when is_map(params) do
        params = params |> Map.drop([:__meta__, :__struct__])

        case schema do
          nil ->
            {:error, "do not find id: `#{params.id}` of resource"}

          article ->
            changeset = article |> changeset(params)

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

      defoverridable add: 2
    end
  end

  defmacro common_fields(:v001) do
    quote bind_quoted: binding() do
      timestamps(type: :utc_datetime_usec)
      field :res_status, :integer, default: 0
    end
  end

  defmacro guaranteed_id(params, do: block) do
    quote do
      case unquote(params).id do
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

  @callback changeset(t :: term, params :: Map.t()) :: term
end
