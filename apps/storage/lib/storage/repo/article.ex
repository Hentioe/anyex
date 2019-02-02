defmodule Storage.Repo.Article do
  @moduledoc false
  use Storage.Schema
  alias Storage.Repo.{Category}
  alias Ecto.{Changeset}

  schema "article" do
    field :qtext
    field :title
    field :content
    field :top, :integer, default: -1

    common_fields(:v001)

    belongs_to :category, Category
  end

  def changeset(article, params \\ %{}) do
    article
    |> Changeset.cast(params, [:qtext, :title, :content, :top, :category_id, @status_field])
    |> Changeset.validate_required([:qtext, :top, :category_id, @status_field])
  end
end
