defmodule CardsProject.Tournaments.Tournament do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tournaments" do
    field :public_id, :string
    field :name, :string
    field :description, :string
    field :status, :string
    field :bracket_data, :map
    field :format, :string
    field :tournament_type, :string
    field :max_players, :integer
    field :entry_fee, :decimal
    field :prize_pool, :decimal
    field :start_time, :naive_datetime
    field :end_time, :naive_datetime
    field :is_online, :boolean, default: true
    field :location, :string
    field :rules_text, :string
    field :created_at, :naive_datetime
    belongs_to :season, CardsProject.Tournaments.Season
    belongs_to :organizer, CardsProject.Players.Player
    many_to_many :judges, CardsProject.Players.Player, join_through: "tournament_judges"
    has_many :judge_assignments, CardsProject.Tournaments.TournamentJudge, foreign_key: :tournament_id
    has_many :registrations, CardsProject.Tournaments.TournamentRegistration, foreign_key: :tournament_id
    has_many :rounds, CardsProject.Tournaments.TournamentRound, foreign_key: :tournament_id
    has_many :prizes, CardsProject.Tournaments.TournamentPrize, foreign_key: :tournament_id
    has_many :streams, CardsProject.Content.Stream, foreign_key: :tournament_id

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:public_id, :name, :max_players, :entry_fee, :prize_pool, :start_time, :is_online, :created_at, :description, :status, :bracket_data, :format, :tournament_type, :end_time, :location, :rules_text, :season_id, :organizer_id])
    |> validate_required([:public_id, :name, :max_players, :entry_fee, :prize_pool, :start_time, :is_online, :created_at])
    |> validate_inclusion(:status, ["Draft", "Registration", "Ongoing", "Completed", "Cancelled"])
    |> validate_inclusion(:format, ["Standard", "Extended", "Legacy", "Vintage", "Commander", "Draft"])
    |> validate_inclusion(:tournament_type, ["Swiss", "SingleElimination", "DoubleElimination", "RoundRobin"])
    |> validate_number(:max_players, greater_than_or_equal_to: 2, less_than_or_equal_to: 512)
    |> unique_constraint(:public_id, message: "public_id must be unique")
    |> validate_number(:max_players, greater_than_or_equal_to: 2, less_than_or_equal_to: 512, message: "Tournament must allow between 2 and 512 players")
    |> validate_number(:entry_fee, greater_than_or_equal_to: 0, message: "Entry fee must not be negative")
    |> validate_number(:prize_pool, greater_than_or_equal_to: 0, message: "Prize pool must not be negative")
    |> then(fn cs ->
      if not is_nil(get_field(cs, :end_time)) and (not ((get_field(cs, :end_time) || 0) > get_field(cs, :start_time))) do
        Ecto.Changeset.add_error(cs, :end_time, "End time must be after start time")
      else
        cs
      end
    end)
  end

  @doc false
  def update_changeset(record, attrs) do
    record
    |> cast(attrs, [:public_id, :name, :max_players, :entry_fee, :prize_pool, :start_time, :is_online, :description, :bracket_data, :format, :tournament_type, :end_time, :location, :rules_text, :season_id, :organizer_id])
    |> validate_required([:public_id, :name, :max_players, :entry_fee, :prize_pool, :start_time, :is_online])
  end

  # ── Business operations ────────────────────────────────────────────

  def start(_record) do
    # TODO: implement Tournament.start
    :ok
  end

  def cancel(_record) do
    # TODO: implement Tournament.cancel
    :ok
  end

  def complete(_record) do
    # TODO: implement Tournament.complete
    :ok
  end

  def generate_round(_record) do
    # TODO: implement Tournament.generate_round
    :ok
  end

  def calculate_prize_distribution(_record) do
    # TODO: implement Tournament.calculate_prize_distribution
    {:error, :not_implemented}
  end

  def register_player(_record, _player_id, _deck_id) do
    # TODO: implement Tournament.register_player
    :ok
  end

  def is_full(_record) do
    # TODO: implement Tournament.is_full
    {:error, :not_implemented}
  end

  # ── Lifecycle state machine ─────────────────────────────────────────
  @allowed_transitions %{
    "Draft" => ["Registration"],
    "Registration" => ["Ongoing", "Cancelled"],
    "Ongoing" => ["Completed", "Cancelled"]
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
