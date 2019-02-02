defmodule Storage.Repo.Article do
  @moduledoc false
  use Storage.Schema

  schema "article" do
    field :qtext
    field :title
    field :content
    field :top, :integer, default: -1

    common_fields(:v001)
  end

  def changeset(article, params \\ %{}) do
    article
    |> Ecto.Changeset.cast(params, [:qtext, :title, :content, :top, @status_field])
    |> Ecto.Changeset.validate_required([:qtext, :top, @status_field])
  end
end
