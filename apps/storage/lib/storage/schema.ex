defmodule Storage.Schema do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Storage.Schema
    end
  end

  defmacro common_fields(:v001) do
    quote bind_quoted: binding() do
      timestamps(type: :utc_datetime_usec)
      field :resource_type, :integer, default: 0
    end
  end
end
