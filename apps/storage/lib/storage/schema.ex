defmodule Storage.Schema do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Storage.Schema

      @status_field :res_status
    end
  end

  defmacro common_fields(:v001) do
    quote bind_quoted: binding() do
      timestamps(type: :utc_datetime_usec)
      field :res_status, :integer, default: 0
    end
  end
end
