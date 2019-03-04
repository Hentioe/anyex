defmodule Storage.Repo.Migrations.CreateSecretSuffix do
  use Storage.Migration

  def change do
    create table(:secret_suffix) do
      add :val, :string, null: false, comment: "密文后缀"

      timestamp_fields(:v001)
    end
  end
end
