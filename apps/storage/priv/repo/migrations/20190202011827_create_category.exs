defmodule Storage.Repo.Migrations.CreateCategory do
  use Storage.Migration

  def change do
    create table(:category) do
      add :qname, :string, null: false, comment: "查询名称"
      add :name, :string, null: false, comment: "类别名称"
      add :description, :text, default: "none", comment: "类别描述"
      add :top, :integer, null: false, default: -1, comment: "类别排序"

      common_fields(:v001)
    end

    create unique_index :category, [:qname, :name]
  end
end
