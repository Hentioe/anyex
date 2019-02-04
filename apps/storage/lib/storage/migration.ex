defmodule Storage.Migration do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Ecto.Migration

      alias Ecto.Migration.Runner

      def common_fields(:v001) do
        opts = Keyword.merge(Runner.repo_config(:migration_timestamps, []), null: false)
        type = :utc_datetime_usec
        add :inserted_at, type, Keyword.merge(opts, comment: "插入时间")
        add :updated_at, type, Keyword.merge(opts, comment: "更新时间")
        add :res_status, :integer, default: 0, null: false, comment: "资源状态"
      end

      def top_field(:v001) do
        add :top, :bigint, null: false, default: -1, comment: "排序状态"
      end
    end
  end
end
