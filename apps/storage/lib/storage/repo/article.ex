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
  def changeset(article, data \\ %{}) do
    article
    |> Changeset.cast(data, [
      :qtext,
      :title,
      :preface,
      :content,
      :top,
      :category_id,
      @status_field
    ])
    |> Changeset.put_assoc(:tags, data.tags)
    |> Changeset.validate_required([:qtext, :title, :top, :category_id, @status_field])
  end

  def add(data), do: add(%__MODULE__{}, data)

  def update(data) do
    guaranteed_id data do
      article = Repo.get(__MODULE__, data.id)
      article |> Repo.preload(:tags) |> update(data)
    end
  end

  def find_list() do
  end
end
