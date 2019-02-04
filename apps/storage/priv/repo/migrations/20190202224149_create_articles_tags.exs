defmodule Storage.Repo.Migrations.CreateArticlesTags do
  use Storage.Migration

  def change do
    create table(:articles_tags, primary_key: false) do
      add :article_id, references(:article), null: false, comment: "文章主键"
      add :tag_id, references(:tag), null: false, comment: "标签主键"
    end
  end
end
