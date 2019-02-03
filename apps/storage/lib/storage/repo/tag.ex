defmodule Storage.Repo.Tag do
  @moduledoc false
  use Storage.Schema
  alias Storage.Repo.{Article}
  alias Ecto.{Changeset}

  schema "tag" do
    field :qname
    field :name
    field :description, :string, default: "none"
    field :top, :integer, default: -1

    common_fields(:v001)

    many_to_many :articles, Article, join_through: "articles_tags"
  end

  @impl Storage.Schema
  def changeset(tag, params \\ %{}) do
    tag
    |> Changeset.cast(params, [:qname, :name, :description, :top, @status_field])
    |> Changeset.validate_required([:qname, :name, :top, @status_field])
  end

  def add(params), do: add(%__MODULE__{}, params)
end
