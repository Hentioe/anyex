defmodule Storage.Repo.Migrations.CreateAritlce do
  use Storage.Migration

  def change do
    create table(:article) do
      add :qtext, :string, null: false
      add :title, :string
      add :content, :text, default: "[WIP]"

      common_fields(:v001)
    end

    create(unique_index(:article, [:qtext]))
  end
end
