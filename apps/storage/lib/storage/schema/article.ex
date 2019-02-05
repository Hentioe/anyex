defmodule Storage.Schema.Article do
  @moduledoc false
  use Storage.Schema

  alias Storage.Repo
  alias Storage.Schema.{Category, Tag, Comment}
  alias Ecto.{Changeset}

  import Ecto.Query, only: [from: 2]

  schema "article" do
    field :qtext
    field :title
    field :preface
    field :content, :string, default: "[WIP]"

    top_field(:v001)
    common_fields(:v001)

    belongs_to :category, Category
    many_to_many :tags, Tag, join_through: "articles_tags", on_replace: :delete
    has_many :comments, Comment
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

  def find_list(filters \\ []) when is_list(filters) do
    res_status = Keyword.get(filters, :res_status)

    tags_query = from t in Tag, select: t

    tags_query =
      if res_status do
        from t in tags_query, where: t.res_status == ^res_status
      else
        tags_query
      end

    query =
      from a in __MODULE__,
        join: c in assoc(a, :category),
        order_by: [desc: a.top, desc: a.updated_at]

    query =
      Enum.reduce(filters, query, fn {key, value}, acc_query ->
        if value == nil do
          acc_query
        else
          case key do
            :res_status ->
              from [a, c] in acc_query,
                where: a.res_status == ^value,
                where: c.res_status == ^value

            :limit ->
              from _ in acc_query,
                limit: ^value

            :offset ->
              from _ in acc_query,
                offset: ^value

            _ ->
              acc_query
          end
        end
      end)

    query = from _ in query, preload: [:category, tags: ^tags_query]

    query |> query_list
  end

  def top(id) do
    top(__MODULE__, id)
  end
end
