defmodule Storage.Schema.SecretSuffix do
  @moduledoc false

  use Storage.Schema

  alias Storage.Repo
  alias Ecto.{Changeset}

  schema "secret_suffix" do
    field :val

    timestamp_fields(:v001)
  end

  @impl Storage.Schema
  def changeset(secret_suffix, data \\ %{}) do
    secret_suffix
    |> Changeset.cast(data, [:val])
    |> Changeset.validate_required([:val])
  end

  def add(data), do: add(%__MODULE__{}, data)

  def generate do
    uuid = UUID.uuid4()
    add(%{val: uuid})
  end

  def update(data) do
    guaranteed_id data do
      secret_suffix = Repo.get(__MODULE__, data.id)
      secret_suffix |> update(data)
    end
  end

  def last_one do
    __MODULE__ |> Ecto.Query.last() |> Repo.one()
  end
end
