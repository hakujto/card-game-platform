defmodule CardsProject.Tournaments.AwardedPrize do
  use Ecto.Schema
  import Ecto.Changeset

  schema "awarded_prizes" do
    field :final_placement, :integer
    field :awarded_at, :naive_datetime
    field :claimed, :boolean, default: false
    field :claimed_at, :naive_datetime
    belongs_to :prize, CardsProject.Tournaments.TournamentPrize
    belongs_to :player, CardsProject.Players.Player

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:final_placement, :awarded_at, :claimed, :claimed_at, :prize_id, :player_id])
    |> validate_required([:final_placement, :awarded_at, :claimed])
  end

  # ── Business operations ────────────────────────────────────────────

  def claim(_record) do
    # TODO: implement AwardedPrize.claim
    :ok
  end
end
