defmodule Storage.Schema.Article do
  @moduledoc false
  use Storage.Schema

  alias Storage.Repo
  alias Storage.Schema.{Category, Tag}
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
    tags = if data[:tags], do: data.tags, else: []

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
    |> Changeset.put_assoc(:tags, tags)
    |> Changeset.validate_required([:qtext, :title, :top, :category_id, @status_field])
  end

  def add(data), do: add(%__MODULE__{}, data)

  def update(data) do
    guaranteed_id data do
      article = Repo.get(__MODULE__, data.id)
      article |> Repo.preload(:tags) |> update(data)
    end
  end

  import Ecto.Query, only: [from: 2]

  def find_list(filters \\ []) when is_list(filters) do
    res_status = Keyword.get(filters, :res_status, 0)
    limit = Keyword.get(filters, :limit, 999)
    offset = Keyword.get(filters, :offset, 0)

    tags_query = from t in Tag, where: t.res_status == ^res_status

    query =
      from a in __MODULE__,
        join: c in assoc(a, :category),
        where: a.res_status == ^res_status,
        where: c.res_status == ^res_status,
        order_by: [desc: a.top, desc: a.updated_at],
        limit: ^limit,
        offset: ^offset,
        preload: [:category, tags: ^tags_query]

    query |> query_list
  end
end
