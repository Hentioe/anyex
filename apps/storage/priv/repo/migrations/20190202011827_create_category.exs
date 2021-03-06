defmodule Storage.Repo.Migrations.CreateCategory do
  use Storage.Migration

  def change do
    create table(:category) do
      add :qname, :string, null: false, comment: "查询名称"
      add :name, :string, null: false, comment: "类别名称"
      add :description, :text, comment: "类别描述"

      top_field(:v001)
      common_fields(:v001)
    end

    create unique_index :category, [:qname, :name]
  end
end
