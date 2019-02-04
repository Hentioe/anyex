defmodule Storage.Repo.Migrations.CreateTweet do
  use Storage.Migration

  def change do
    create table(:tweet) do
      add :color, :string, comment: "推文颜色"
      add :conetnt, :text, null: false, comment: "推文内容"
      add :top, :integer, null: false, default: -1, comment: "推文排序"

      common_fields(:v001)
    end
  end
end
