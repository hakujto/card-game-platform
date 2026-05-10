defmodule CardsProject.Tournaments.TournamentRound do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tournament_rounds" do
    field :round_number, :integer
    field :status, :string
    field :started_at, :naive_datetime
    field :ended_at, :naive_datetime
    field :time_limit_minutes, :integer, default: 50
    belongs_to :tournament, CardsProject.Tournaments.Tournament
    belongs_to :matches, CardsProject.Tournaments.Match

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:round_number, :time_limit_minutes, :status, :started_at, :ended_at, :tournament_id, :matches_id])
    |> validate_required([:round_number, :time_limit_minutes])
    |> validate_inclusion(:status, ["Pending", "Active", "Completed"])
  end
end
