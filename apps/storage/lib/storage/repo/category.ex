defmodule Storage.Repo.Category do
  @moduledoc false
  use Storage.Schema
  alias Storage.Repo.{Article}
  alias Ecto.{Changeset}

  schema "category" do
    field :qname
    field :name
    field :description
    field :top, :integer, default: -1

    common_fields(:v001)

    has_many :articles, Article
  end

  def changeset(category, params \\ %{}) do
    category
    |> Changeset.cast(params, [:qname, :name, :description, :top, @status_field])
    |> Changeset.validate_required([:qname, :name, :top, @status_field])
  end
end
