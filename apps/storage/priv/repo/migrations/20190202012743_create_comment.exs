defmodule Storage.Repo.Migrations.CreateComment do
  use Storage.Migration

  def change do
    create table(:comment) do
      add :author_nickname, :string, null: false, comment: "作者昵称"
      add :author_email, :string, null: false, comment: "作者邮箱"
      add :personal_site, :string, comment: "个人主页"
      add :content, :text, null: false, comment: "评论内容"

      top_field(:v001)
      common_fields(:v001)
    end
  end
end
