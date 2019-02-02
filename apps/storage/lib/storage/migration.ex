defmodule Storage.Migration do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Ecto.Migration

      def common_fields(:v001) do
        timestamps(type: :utc_datetime_usec)
        add :res_status, :integer, default: 0, null: false, comment: "资源状态"
      end
    end
  end
end
