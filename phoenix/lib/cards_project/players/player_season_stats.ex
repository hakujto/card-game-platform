defmodule CardsProject.Players.PlayerSeasonStats do
  use Ecto.Schema
  import Ecto.Changeset

  schema "player_season_statses" do
    field :wins, :integer, default: 0
    field :losses, :integer, default: 0
    field :draws, :integer, default: 0
    field :tournament_wins, :integer, default: 0
    field :highest_rank, :string
    field :season_points, :integer, default: 0
    belongs_to :player, CardsProject.Players.Player
    belongs_to :season, CardsProject.Tournaments.Season

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:wins, :losses, :draws, :tournament_wins, :season_points, :highest_rank, :player_id, :season_id])
    |> validate_required([:wins, :losses, :draws, :tournament_wins, :season_points])
    |> validate_inclusion(:highest_rank, ["Bronze", "Silver", "Gold", "Platinum", "Diamond", "Master", "Grandmaster"])
  end

  # ── Business operations ────────────────────────────────────────────

  def win_rate(_record) do
    # TODO: implement PlayerSeasonStats.win_rate
    {:error, :not_implemented}
  end

  def add_points(_record, _points) do
    # TODO: implement PlayerSeasonStats.add_points
    :ok
  end

  def record_tournament_win(_record) do
    # TODO: implement PlayerSeasonStats.record_tournament_win
    :ok
  end
end
