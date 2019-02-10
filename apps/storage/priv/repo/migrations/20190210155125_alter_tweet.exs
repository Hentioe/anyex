defmodule Storage.Repo.Migrations.AlterTweet do
  use Storage.Migration

  def change do
    rename(table(:tweet), :color, to: :theme)
    rename(table(:tweet), :conetnt, to: :content)

    alter table(:tweet) do
      modify(:theme, :string, comment: "主题风格")
    end
  end
end
