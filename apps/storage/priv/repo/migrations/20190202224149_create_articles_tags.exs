defmodule Storage.Repo.Migrations.CreateArticlesTags do
  use Storage.Migration

  def change do
    create table(:articles_tags, primary_key: false) do
      add :article_id, references(:article)
      add :tag_id, references(:tag)
    end
  end
end
