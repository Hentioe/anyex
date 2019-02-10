defmodule Storage.Schema.Tweet do
  @moduledoc false

  use Storage.Schema

  alias Storage.Repo
  alias Ecto.{Changeset}

  import Ecto.Query, only: [from: 2]

  @derive {Jason.Encoder, only: [:id, :theme, :content, @top_field] ++ @common_fields}
  schema "tweet" do
    field :theme
    field :content

    top_field(:v001)
    common_fields(:v001)
  end

  @impl Storage.Schema
  def changeset(tweet, data \\ %{}) do
    tweet
    |> Changeset.cast(data, [:theme, :content, :top, @status_field])
    |> Changeset.validate_required([:content, :top, @status_field])
  end

  def add(data), do: add(%__MODULE__{}, data)

  def update(data) do
    guaranteed_id data do
      tag = Repo.get(__MODULE__, data.id)
      tag |> update(data)
    end
  end

  def find_list(filters \\ []) when is_list(filters) do
    query =
      from t in __MODULE__,
        order_by: [desc: t.top, desc: t.inserted_at]

    query =
      Enum.reduce(filters, query, fn {key, value}, acc_query ->
        if value == nil do
          acc_query
        else
          case key do
            :res_status ->
              from t in acc_query,
                where: t.res_status == ^value

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

    query |> query_list
  end

  def top(id) do
    top(__MODULE__, id)
  end
end
