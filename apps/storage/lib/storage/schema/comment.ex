defmodule Storage.Schema.Comment do
  @moduledoc false
  use Storage.Schema

  alias Storage.Repo
  alias Storage.Schema.{Article}
  alias Ecto.{Changeset}

  import Ecto.Query, only: [from: 2]

  @derive {Jason.Encoder,
           only:
             [:id, :author_nickname, :personal_site, :content, :owner, @top_field] ++
               @common_fields ++ [:comments]}
  schema "comment" do
    field :author_nickname
    field :author_email
    field :personal_site
    field :content
    field :owner, :boolean, default: false

    top_field(:v001)
    common_fields(:v001)

    belongs_to :article, Article
    belongs_to :parent, __MODULE__
    has_many :comments, __MODULE__, foreign_key: :parent_id
  end

  @impl Storage.Schema
  def changeset(comment, data \\ %{}) do
    comment
    |> Changeset.cast(data, [
      :author_nickname,
      :author_email,
      :personal_site,
      :content,
      :owner,
      :top,
      :article_id,
      :parent_id,
      @status_field
    ])
    |> Changeset.validate_required([
      :author_nickname,
      :author_email,
      :content,
      :owner,
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

  def find_list(filters \\ []) when is_list(filters) do
    res_status = Keyword.get(filters, :res_status)

    query =
      from c in __MODULE__,
        order_by: [desc: c.top, desc: c.inserted_at]

    subcommentds_query =
      from c in __MODULE__, select: c, order_by: [desc: c.top, desc: c.inserted_at]

    subcommentds_query =
      if res_status do
        from c in query, where: c.res_status == ^res_status
      else
        subcommentds_query
      end

    query =
      Enum.reduce(filters, query, fn {key, value}, acc_query ->
        if value == nil do
          acc_query
        else
          case key do
            :res_status ->
              from [c, sc] in acc_query,
                where: c.res_status == ^value,
                where: sc.res_status == ^value

            :limit ->
              from _ in acc_query,
                limit: ^value

            :offset ->
              from _ in acc_query,
                offset: ^value

            :article_id ->
              from c in acc_query,
                where: c.article_id == ^value,
                where: is_nil(c.parent_id)

            _ ->
              acc_query
          end
        end
      end)

    query = from _ in query, preload: [comments: ^subcommentds_query]

    query |> query_list
  end

  def top(id) do
    top(__MODULE__, id)
  end
end
