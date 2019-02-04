defmodule Storage.Repo.Migrations.CreateCommentForeignKey do
  use Storage.Migration

  def change do
    alter table(:comment) do
      add :article_id, references(:article), null: false, comment: "关联文章"
    end
  end
end
