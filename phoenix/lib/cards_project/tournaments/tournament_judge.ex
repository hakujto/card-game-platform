defmodule CardsProject.Tournaments.TournamentJudge do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tournament_judges" do
    field :role, :string
    belongs_to :tournament, CardsProject.Tournaments.Tournament
    belongs_to :player, CardsProject.Players.Player

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:role, :tournament_id, :player_id])
    |> validate_inclusion(:role, ["HeadJudge", "Judge", "ScorekeeperJudge"])
  end

  # ── Business operations ────────────────────────────────────────────

  def promote_to_head(_record) do
    # TODO: implement TournamentJudge.promote_to_head
    :ok
  end

  def remove(_record) do
    # TODO: implement TournamentJudge.remove
    :ok
  end
end
