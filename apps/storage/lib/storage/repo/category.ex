defmodule Storage.Repo.Category do
  @moduledoc false
  use Storage.Schema
  alias Storage.Repo.{Article}
  alias Ecto.{Changeset}

  schema "category" do
    field :qname
    field :name
    field :description, :string, default: "none"
    field :top, :integer, default: -1

    common_fields(:v001)

    has_many :articles, Article
  end

  @impl Storage.Schema
  def changeset(category, data \\ %{}) do
    category
    |> Changeset.cast(data, [:qname, :name, :description, :top, @status_field])
    |> Changeset.validate_required([:qname, :name, :top, @status_field])
  end

  def add(data), do: add(%__MODULE__{}, data)
end
