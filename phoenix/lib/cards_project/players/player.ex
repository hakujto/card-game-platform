defmodule CardsProject.Players.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :display_name, :string
    field :rank, :string
    field :rating, :integer, default: 1000
    field :peak_rating, :integer, default: 1000
    field :bio, :string
    field :country_code, :string
    field :avatar_url, :string
    field :preferred_format, :string
    field :is_verified, :boolean, default: false
    field :created_at, :naive_datetime
    field :last_active_at, :naive_datetime
    belongs_to :user, CardsProject.Accounts.User
    belongs_to :season_stats, CardsProject.Players.PlayerSeasonStats
    many_to_many :achievements, CardsProject.Players.Achievement, join_through: "player_achievements_m2m"
    many_to_many :friends, CardsProject.Players.Player, join_through: "player_friends_m2m"

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:display_name, :rating, :peak_rating, :is_verified, :created_at, :rank, :bio, :country_code, :avatar_url, :preferred_format, :last_active_at, :user_id])
    |> validate_required([:display_name, :rating, :peak_rating, :is_verified, :created_at])
    |> validate_inclusion(:rank, ["Bronze", "Silver", "Gold", "Platinum", "Diamond", "Master", "Grandmaster"])
    |> validate_inclusion(:preferred_format, ["Standard", "Extended", "Legacy", "Vintage", "Commander", "Draft"])
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
