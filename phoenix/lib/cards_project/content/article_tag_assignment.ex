defmodule CardsProject.Content.ArticleTagAssignment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "article_tag_assignments" do
    belongs_to :article, CardsProject.Content.Article
    belongs_to :tag, CardsProject.Content.ArticleTag

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:article_id, :tag_id])
  end
end
