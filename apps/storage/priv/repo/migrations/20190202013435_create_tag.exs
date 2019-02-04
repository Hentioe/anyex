defmodule Storage.Repo.Migrations.CreateTag do
  use Storage.Migration

  def change do
    create table(:tag) do
      add :qname, :string, null: false, comment: "查询名称"
      add :name, :string, null: false, comment: "标签名称"
      add :description, :text, comment: "标签描述"

      top_field(:v001)
      common_fields(:v001)
    end

    create unique_index :tag, [:qname, :name]
  end
end
