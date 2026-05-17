defmodule CardsProject.Content.Article do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :title, :string
    field :slug, :string
    field :body, :string
    field :excerpt, :string
    field :cover_image_url, :string
    field :status, :string
    field :article_type, :string
    field :view_count, :integer, default: 0
    field :published_at, :naive_datetime
    field :created_at, :naive_datetime
    belongs_to :author, CardsProject.Players.Player
    belongs_to :featured_deck, CardsProject.Cards.Deck
    belongs_to :comments, CardsProject.Content.ArticleComment
    many_to_many :tags, CardsProject.Content.ArticleTag, join_through: "article_tags_m2m"

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:title, :slug, :body, :view_count, :created_at, :excerpt, :cover_image_url, :status, :article_type, :published_at, :author_id, :featured_deck_id])
    |> validate_required([:title, :slug, :body, :view_count, :created_at])
    |> validate_inclusion(:status, ["Draft", "Published", "Archived"])
    |> validate_inclusion(:article_type, ["Guide", "Tierlist", "Matchup", "News", "Spotlight", "Decklist"])
  end

  # ── Business operations ────────────────────────────────────────────

  def publish(_record) do
    # TODO: implement Article.publish
    :ok
  end

  def archive(_record) do
    # TODO: implement Article.archive
    :ok
  end

  def increment_view(_record) do
    # TODO: implement Article.increment_view
    :ok
  end

  def reading_time_minutes(_record) do
    # TODO: implement Article.reading_time_minutes
    {:error, :not_implemented}
  end
end
