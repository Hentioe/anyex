defmodule Storage.Schema do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Storage.Schema
      @behaviour Storage.Schema

      @status_field :res_status

      @spec add(term, Map.t()) :: {:ok, term} | {:error, term}
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

      defoverridable add: 2
    end
  end

  defmacro common_fields(:v001) do
    quote bind_quoted: binding() do
      timestamps(type: :utc_datetime_usec)
      field :res_status, :integer, default: 0
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
