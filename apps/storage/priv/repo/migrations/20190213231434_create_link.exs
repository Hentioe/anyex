defmodule Storage.Repo.Migrations.CreateLink do
  use Storage.Migration

  def change do
    create table(:link) do
      add :text, :string, null: false, comment: "链接文本"
      add :address, :string, null: false, comment: "链接地址"
      add :description, :text, comment: "链接描述"
      add :type, :integer, null: false, comment: "链接类型"

      top_field(:v001)
      common_fields(:v001)
    end

    execute("ALTER SEQUENCE link_id_seq START with 1000 RESTART")
  end
end
