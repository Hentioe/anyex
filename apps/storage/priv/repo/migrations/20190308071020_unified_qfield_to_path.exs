defmodule Storage.Repo.Migrations.UnifiedQfieldToPath do
  use Storage.Migration

  def change do
    rename(table(:article), :qtext, to: :path)
    rename(table(:category), :qname, to: :path)
    rename(table(:tag), :qname, to: :path)
  end
end
