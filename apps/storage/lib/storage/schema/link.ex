defmodule Storage.Schema.Link do
  @moduledoc false

  use Storage.Schema

  alias Storage.Repo
  alias Ecto.{Changeset}

  import Ecto.Query, only: [from: 2]

  @derive {Jason.Encoder, only: [:id, :qname, :name, :description, @top_field] ++ @common_fields}
  schema "link" do
    field :text
    field :address
    field :description, :string, default: "none"
    field :type, :integer

    top_field(:v001)
    common_fields(:v001)
  end

  @impl Storage.Schema
  def changeset(link, data \\ %{}) do
    link
    |> Changeset.cast(data, [:text, :address, :description, :type, :top, @status_field])
    |> Changeset.validate_required([:text, :address, :type, :top, @status_field])
  end

  def add(data), do: add(%__MODULE__{}, data)

  def update(data) do
    guaranteed_id data do
      link = Repo.get(__MODULE__, data.id)
      link |> update(data)
    end
  end

  def find_list(filters \\ []) when is_list(filters) do
    query =
      from l in __MODULE__,
        order_by: [desc: l.top]

    query =
      Enum.reduce(filters, query, fn {key, value}, acc_query ->
        if value == nil do
          acc_query
        else
          case key do
            :res_status ->
              from l in acc_query,
                where: l.res_status == ^value

            :limit ->
              from _ in acc_query,
                limit: ^value

            :offset ->
              from _ in acc_query,
                offset: ^value

            :type ->
              from l in acc_query, where: l.type == ^value

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
