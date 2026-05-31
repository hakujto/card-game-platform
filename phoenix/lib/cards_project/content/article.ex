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
    field :language, :string
    field :view_count, :integer, default: 0
    field :likes_count, :integer, default: 0
    field :is_featured, :boolean, default: false
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
    |> cast(attrs, [:title, :slug, :body, :view_count, :likes_count, :is_featured, :created_at, :excerpt, :cover_image_url, :status, :article_type, :language, :published_at, :author_id, :featured_deck_id])
    |> validate_required([:title, :slug, :body, :view_count, :likes_count, :is_featured, :created_at])
    |> validate_inclusion(:status, ["Draft", "Published", "Archived"])
    |> validate_inclusion(:article_type, ["Guide", "Tierlist", "Matchup", "News", "Spotlight", "Decklist"])
    |> validate_inclusion(:language, ["EN", "DE", "FR", "IT", "ES", "JP", "PT"])
    |> validate_number(:view_count, greater_than_or_equal_to: 0, message: "Article view count must not be negative")
    |> validate_number(:likes_count, greater_than_or_equal_to: 0, message: "Article likes count must not be negative")
    |> then(fn cs ->
      if get_field(cs, :status) == "Published" and (is_nil(get_field(cs, :published_at))) do
        Ecto.Changeset.add_error(cs, :published_at, "Published article must have a published_at timestamp")
      else
        cs
      end
    end)
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

  def like(_record) do
    # TODO: implement Article.like
    :ok
  end

  def unlike(_record) do
    # TODO: implement Article.unlike
    :ok
  end

  def reading_time_minutes(_record) do
    # TODO: implement Article.reading_time_minutes
    {:error, :not_implemented}
  end

  # ── Lifecycle state machine ─────────────────────────────────────────
  @allowed_transitions %{
    "Draft" => ["Published"],
    "Published" => ["Archived"],
    "Archived" => ["Draft"]
  }

  def assert_transition(%__MODULE__{status: current}, to) do
    allowed = Map.get(@allowed_transitions, current, [])
    if to in allowed do
      :ok
    else
      {:error, "Transition #{current} -> #{to} not allowed"}
    end
  end
end
