defmodule Storage.Schema.Category do
  @moduledoc false
  use Storage.Schema

  alias Storage.Repo
  alias Storage.Schema.{Article}
  alias Ecto.{Changeset}

  import Ecto.Query, only: [from: 2]

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

  def update(data) do
    guaranteed_id data do
      category = Repo.get(__MODULE__, data.id)
      category |> update(data)
    end
  end

  def find_list(filters \\ []) when is_list(filters) do
    res_status = Keyword.get(filters, :res_status, 0)
    limit = Keyword.get(filters, :limit, 999)
    offset = Keyword.get(filters, :offset, 0)

    query =
      from c in __MODULE__,
        where: c.res_status == ^res_status,
        order_by: [desc: c.top],
        limit: ^limit,
        offset: ^offset

    query |> query_list
  end
end
