defmodule CardsProject.Content.ArticleTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "article_tags" do
    field :name, :string
    field :slug, :string
    has_many :article_assignments, CardsProject.Content.ArticleTagAssignment, foreign_key: :tag_id

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> unique_constraint(:slug, message: "slug must be unique")
  end

  # ── Business operations ────────────────────────────────────────────

  def rename(_record, _new_name) do
    # TODO: implement ArticleTag.rename
    :ok
  end

  def article_count(_record) do
    # TODO: implement ArticleTag.article_count
    {:error, :not_implemented}
  end
end
