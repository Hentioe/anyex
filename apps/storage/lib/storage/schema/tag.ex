defmodule Storage.Schema.Tag do
  @moduledoc false

  use Storage.Schema

  alias Storage.Repo
  alias Storage.Schema.{Article}
  alias Ecto.{Changeset}

  import Ecto.Query, only: [from: 2]

  @derive {Jason.Encoder, only: [:id, :qname, :name, :description, @top_field] ++ @common_fields}
  schema "tag" do
    field :qname
    field :name
    field :description, :string, default: "none"
    field :top, :integer, default: -1

    common_fields(:v001)

    many_to_many :articles, Article, join_through: "articles_tags"
  end

  @impl Storage.Schema
  def changeset(tag, data \\ %{}) do
    tag
    |> Changeset.cast(data, [:qname, :name, :description, :top, @status_field])
    |> Changeset.validate_required([:qname, :name, :top, @status_field])
  end

  def add(data), do: add(%__MODULE__{}, data)

  def update(data) do
    guaranteed_id data do
      tag = Repo.get(__MODULE__, data.id)
      tag |> update(data)
    end
  end

  def find_list(filters \\ []) when is_list(filters) do
    res_status = Keyword.get(filters, :res_status, 0)
    limit = Keyword.get(filters, :limit, 999)
    offset = Keyword.get(filters, :offset, 0)

    query =
      from t in __MODULE__,
        where: t.res_status == ^res_status,
        order_by: [desc: t.top],
        limit: ^limit,
        offset: ^offset

    query |> query_list
  end

  def top(id) do
    top(__MODULE__, id)
  end
end
