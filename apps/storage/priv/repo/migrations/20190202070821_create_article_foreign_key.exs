defmodule Storage.Repo.Migrations.CreateArticleForeignKey do
  use Storage.Migration

  def change do
    alter table(:article) do
      add :category_id, references(:category), null: false, comment: "关联类别"
    end
  end
end
