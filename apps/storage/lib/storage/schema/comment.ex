defmodule Storage.Schema.Comment do
  @moduledoc false
  use Storage.Schema

  alias Storage.Repo
  alias Storage.Schema.{Article}
  alias Ecto.{Changeset}

  import Ecto.Query, only: [from: 2]

  schema "comment" do
    field :author_nickname
    field :author_email
    field :personal_site
    field :content
    field :top, :integer, default: -1

    common_fields(:v001)

    belongs_to :article, Article
  end

  @impl Storage.Schema
  def changeset(comment, data \\ %{}) do
    comment
    |> Changeset.cast(data, [
      :author_nickname,
      :author_email,
      :personal_site,
      :content,
      :top,
      :article_id,
      @status_field
    ])
    |> Changeset.validate_required([
      :author_nickname,
      :author_email,
      :content,
      :top,
      :article_id,
      @status_field
    ])
  end

  def add(data), do: add(%__MODULE__{}, data)

  def update(data) do
    guaranteed_id data do
      comment = Repo.get(__MODULE__, data.id)
      comment |> update(data)
    end
  end
end
