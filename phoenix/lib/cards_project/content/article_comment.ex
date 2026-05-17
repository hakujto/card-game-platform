defmodule CardsProject.Content.ArticleComment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "article_comments" do
    field :body, :string
    field :is_hidden, :boolean, default: false
    field :created_at, :naive_datetime
    belongs_to :article, CardsProject.Content.Article
    belongs_to :author, CardsProject.Players.Player
    belongs_to :parent_comment, CardsProject.Content.ArticleComment

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:body, :is_hidden, :created_at, :article_id, :author_id, :parent_comment_id])
    |> validate_required([:body, :is_hidden, :created_at])
  end

  # ── Business operations ────────────────────────────────────────────

  def hide(_record) do
    # TODO: implement ArticleComment.hide
    :ok
  end

  def unhide(_record) do
    # TODO: implement ArticleComment.unhide
    :ok
  end

  def is_reply(_record) do
    # TODO: implement ArticleComment.is_reply
    {:error, :not_implemented}
  end
end
