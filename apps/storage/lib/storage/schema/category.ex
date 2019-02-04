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
    res_status = Keyword.get(filters, :res_status)
    limit = Keyword.get(filters, :limit)
    offset = Keyword.get(filters, :offset)

    query =
      from c in __MODULE__,
        order_by: [desc: c.top]

    query =
      Enum.reduce(filters, query, fn {key, value}, acc_query ->
        if value == nil do
          acc_query
        else
          case key do
            :res_status ->
              from c in acc_query,
                where: c.res_status == ^res_status

            :limit ->
              from _ in acc_query,
                limit: ^limit

            :offset ->
              from _ in acc_query,
                offset: ^offset

            _ ->
              acc_query
          end
        end
      end)

    query |> query_list
  end

  def top(id) do
    top(__MODULE__, id)
  end
end
