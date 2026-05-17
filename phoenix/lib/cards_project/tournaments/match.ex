defmodule CardsProject.Tournaments.Match do
  use Ecto.Schema
  import Ecto.Changeset

  schema "matches" do
    field :table_number, :integer
    field :status, :string
    field :player1_wins, :integer, default: 0
    field :player2_wins, :integer, default: 0
    field :started_at, :naive_datetime
    field :ended_at, :naive_datetime
    field :result_notes, :string
    belongs_to :round, CardsProject.Tournaments.TournamentRound
    belongs_to :player1, CardsProject.Players.Player
    belongs_to :player2, CardsProject.Players.Player
    belongs_to :games, CardsProject.Tournaments.Game

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:player1_wins, :player2_wins, :table_number, :status, :started_at, :ended_at, :result_notes, :round_id, :player1_id, :player2_id])
    |> validate_required([:player1_wins, :player2_wins])
    |> validate_inclusion(:status, ["Pending", "Active", "Completed", "BYE", "Draw"])
  end

  # ── Business operations ────────────────────────────────────────────

  def record_result(_record, _p1_wins, _p2_wins) do
    # TODO: implement Match.record_result
    :ok
  end

  def determine_winner(_record) do
    # TODO: implement Match.determine_winner
    {:error, :not_implemented}
  end

  def draw(_record) do
    # TODO: implement Match.draw
    :ok
  end
end
