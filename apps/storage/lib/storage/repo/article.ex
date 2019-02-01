defmodule Storage.Repo.Article do
  @moduledoc false
  use Storage.Schema

  def common_fields(:v001) do
  end

  schema "article" do
    field :qtext
    field :title
    field :content

    common_fields(:v001)
  end

  def changeset(article, params \\ %{}) do
    article
    |> Ecto.Changeset.cast(params, [:qtext, :title, :content, :resource_status])
    |> Ecto.Changeset.validate_required([:qtext, :resource_status])
  end
end
