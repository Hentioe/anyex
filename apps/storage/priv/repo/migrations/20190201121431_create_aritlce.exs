defmodule Storage.Repo.Migrations.CreateAritlce do
  use Storage.Migration

  def change do
    create table(:article) do
      add :qtext, :string, null: false, comment: "查询文本"
      add :title, :string, null: false, comment: "文章标题"
      add :preface, :text, comment: "文章前言"
      add :content, :text, comment: "文章内容"

      top_field(:v001)
      common_fields(:v001)
    end

    create unique_index :article, [:qtext, :title]
  end
end
