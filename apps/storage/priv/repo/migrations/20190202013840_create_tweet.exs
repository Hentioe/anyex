defmodule Storage.Repo.Migrations.CreateTweet do
  use Storage.Migration

  def change do
    create table(:tweet) do
      add :color, :string, comment: "Tweet 颜色"
      add :conetnt, :text, null: false, comment: "Tweet 内容"
      add :top, :integer, null: false, default: -1, comment: "Tweet 排序"

      common_fields(:v001)
    end
  end
end
