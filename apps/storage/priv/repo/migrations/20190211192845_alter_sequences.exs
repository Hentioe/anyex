defmodule Storage.Repo.Migrations.AlterSequences do
  use Storage.Migration

  def change do
    execute("ALTER SEQUENCE article_id_seq START with 1000 RESTART")
    execute("ALTER SEQUENCE category_id_seq START with 1000 RESTART")
    execute("ALTER SEQUENCE comment_id_seq START with 1000 RESTART")
    execute("ALTER SEQUENCE tag_id_seq START with 1000 RESTART")
    execute("ALTER SEQUENCE tweet_id_seq START with 1000 RESTART")
  end
end
