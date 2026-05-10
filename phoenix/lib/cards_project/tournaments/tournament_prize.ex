defmodule CardsProject.Tournaments.TournamentPrize do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tournament_prizes" do
    field :placement_from, :integer
    field :placement_to, :integer
    field :prize_type, :string
    field :amount, :decimal
    field :description, :string
    field :packs_count, :integer
    field :season_points, :integer, default: 0
    belongs_to :tournament, CardsProject.Tournaments.Tournament

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:placement_from, :placement_to, :amount, :season_points, :prize_type, :description, :packs_count, :tournament_id])
    |> validate_required([:placement_from, :placement_to, :amount, :season_points])
    |> validate_inclusion(:prize_type, ["Currency", "Cards", "BoosterPacks", "Trophy", "SeasonPoints", "Mixed"])
  end
end
