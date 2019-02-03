defmodule Storage.Repo.Article do
  @moduledoc false
  use Storage.Schema

  alias Storage.Repo
  alias Storage.Repo.{Category, Tag}
  alias Ecto.{Changeset}

  schema "article" do
    field :qtext
    field :title
    field :preface
    field :content, :string, default: "[WIP]"
    field :top, :integer, default: -1

    common_fields(:v001)

    belongs_to :category, Category
    many_to_many :tags, Tag, join_through: "articles_tags", on_replace: :delete
  end

  @impl Storage.Schema
  def changeset(article, params \\ %{}) do
    article
    |> Changeset.cast(params, [
      :qtext,
      :title,
      :preface,
      :content,
      :top,
      :category_id,
      @status_field
    ])
    |> Changeset.put_assoc(:tags, params.tags)
    |> Changeset.validate_required([:qtext, :title, :top, :category_id, @status_field])
  end

  def add(params), do: add(%__MODULE__{}, params)

  def update(params) do
    guaranteed_id params do
      Repo.get(__MODULE__, params.id) |> Repo.preload(:tags) |> update(params)
    end
  end
end
