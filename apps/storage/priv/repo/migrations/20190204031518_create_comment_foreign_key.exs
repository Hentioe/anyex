defmodule Storage.Repo.Migrations.CreateCommentForeignKey do
  use Storage.Migration

  def change do
    alter table(:comment) do
      add :article_id, references(:article), null: false, comment: "关联文章"
      add :parent_id, references(:comment), null: true, comment: "父级评论"
    end
  end
end
