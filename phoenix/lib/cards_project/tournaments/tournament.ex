defmodule CardsProject.Tournaments.Tournament do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tournaments" do
    field :name, :string
    field :description, :string
    field :format, :string
    field :tournament_type, :string
    field :status, :string
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
    belongs_to :registrations, CardsProject.Tournaments.TournamentRegistration
    belongs_to :rounds, CardsProject.Tournaments.TournamentRound
    belongs_to :prizes, CardsProject.Tournaments.TournamentPrize
    many_to_many :judges, CardsProject.Players.Player, join_through: "tournament_judges_m2m"

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:name, :max_players, :entry_fee, :prize_pool, :start_time, :is_online, :created_at, :description, :format, :tournament_type, :status, :end_time, :location, :rules_text, :season_id, :organizer_id, :registrations_id, :rounds_id, :prizes_id])
    |> validate_required([:name, :max_players, :entry_fee, :prize_pool, :start_time, :is_online, :created_at])
    |> validate_inclusion(:format, ["Standard", "Extended", "Legacy", "Vintage", "Commander", "Draft"])
    |> validate_inclusion(:tournament_type, ["Swiss", "SingleElimination", "DoubleElimination", "RoundRobin"])
    |> validate_inclusion(:status, ["Draft", "Registration", "Ongoing", "Completed", "Cancelled"])
  end
end
