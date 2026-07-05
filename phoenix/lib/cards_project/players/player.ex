defmodule CardsProject.Players.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :public_id, :string
    field :display_name, :string
    field :rank, :string
    field :rating, :integer, default: 1000
    field :peak_rating, :integer, default: 1000
    field :bio, :string
    field :country_code, :string
    field :avatar_url, :string
    field :preferred_format, :string
    field :contact_email, :string
    field :win_rate_cached, :float
    field :is_verified, :boolean, default: false
    field :created_at, :naive_datetime
    field :last_active_at, :naive_datetime
    belongs_to :user, CardsProject.Accounts.User
    many_to_many :achievements, CardsProject.Players.Achievement, join_through: "player_achievements"
    many_to_many :friends, CardsProject.Players.Player, join_through: "friendships"
    has_many :decks, CardsProject.Cards.Deck, foreign_key: :player_id
    has_many :season_stats, CardsProject.Players.PlayerSeasonStats, foreign_key: :player_id
    has_many :collection, CardsProject.Players.PlayerCollection, foreign_key: :player_id
    has_many :sent_friend_requests, CardsProject.Players.Friendship, foreign_key: :requester_id
    has_many :received_friend_requests, CardsProject.Players.Friendship, foreign_key: :receiver_id
    has_many :achievement_records, CardsProject.Players.PlayerAchievement, foreign_key: :player_id
    has_many :organized_tournaments, CardsProject.Tournaments.Tournament, foreign_key: :organizer_id
    many_to_many :judged_tournaments, CardsProject.Tournaments.Tournament, join_through: "tournament_judges"
    has_many :judge_roles, CardsProject.Tournaments.TournamentJudge, foreign_key: :player_id
    has_many :tournament_registrations, CardsProject.Tournaments.TournamentRegistration, foreign_key: :player_id
    has_many :matches_as_player1, CardsProject.Tournaments.Match, foreign_key: :player1_id
    has_many :matches_as_player2, CardsProject.Tournaments.Match, foreign_key: :player2_id
    has_many :won_games, CardsProject.Tournaments.Game, foreign_key: :winner_id
    has_many :awarded_prizes, CardsProject.Tournaments.AwardedPrize, foreign_key: :player_id
    has_many :orders, CardsProject.Marketplace.Order, foreign_key: :player_id
    has_many :trade_listings, CardsProject.Marketplace.TradeListing, foreign_key: :seller_id
    has_many :bids, CardsProject.Marketplace.TradeBid, foreign_key: :bidder_id
    has_many :purchases, CardsProject.Marketplace.TradeTransaction, foreign_key: :buyer_id
    has_many :sales, CardsProject.Marketplace.TradeTransaction, foreign_key: :seller_id
    has_many :disputes_opened, CardsProject.Marketplace.TradeDispute, foreign_key: :opened_by_id
    has_many :disputes_resolved, CardsProject.Marketplace.TradeDispute, foreign_key: :resolved_by_id
    has_many :draft_sessions, CardsProject.Content.DraftParticipant, foreign_key: :player_id
    has_many :articles, CardsProject.Content.Article, foreign_key: :author_id
    has_many :article_comments, CardsProject.Content.ArticleComment, foreign_key: :author_id
    has_many :streams, CardsProject.Content.Stream, foreign_key: :streamer_id

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:public_id, :display_name, :rating, :peak_rating, :is_verified, :created_at, :rank, :bio, :country_code, :avatar_url, :preferred_format, :contact_email, :win_rate_cached, :last_active_at, :user_id])
    |> validate_required([:public_id, :display_name, :rating, :peak_rating, :is_verified, :created_at])
    |> validate_inclusion(:rank, ["Bronze", "Silver", "Gold", "Platinum", "Diamond", "Master", "Grandmaster"])
    |> validate_inclusion(:preferred_format, ["Standard", "Extended", "Legacy", "Vintage", "Commander", "Draft"])
    |> validate_format(:country_code, ~r/[A-Z]{2}/)
    |> unique_constraint(:public_id, message: "public_id must be unique")
    |> unique_constraint(:display_name, message: "display_name must be unique")
    |> validate_number(:rating, greater_than_or_equal_to: 0, less_than_or_equal_to: 9999, message: "Rating must be between 0 and 9999")
    |> then(fn cs ->
      lv = get_field(cs, :rating)
      fv = get_field(cs, :peak_rating)
      if not is_nil(lv) and not is_nil(fv) and not (fv >= lv) do
        Ecto.Changeset.add_error(cs, :peak_rating, "Peak rating must be greater than or equal to current rating")
      else
        cs
      end
    end)
  end

  @doc false
  def update_changeset(record, attrs) do
    record
    |> cast(attrs, [:public_id, :display_name, :is_verified, :rank, :bio, :country_code, :avatar_url, :preferred_format, :contact_email, :win_rate_cached, :last_active_at, :user_id])
    |> validate_required([:public_id, :display_name, :is_verified])
  end

  # ── Business operations ────────────────────────────────────────────

  def promote(_record) do
    # TODO: implement Player.promote
    {:error, :not_implemented}
  end

  def demote(_record) do
    # TODO: implement Player.demote
    {:error, :not_implemented}
  end

  def record_win(_record) do
    # TODO: implement Player.record_win
    :ok
  end

  def record_loss(_record) do
    # TODO: implement Player.record_loss
    :ok
  end

  def win_rate(_record) do
    # TODO: implement Player.win_rate
    {:error, :not_implemented}
  end

  def verify(_record) do
    # TODO: implement Player.verify
    :ok
  end

  def update_rating(_record, _delta) do
    # TODO: implement Player.update_rating
    :ok
  end
end
