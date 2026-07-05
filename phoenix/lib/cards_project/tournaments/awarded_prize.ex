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
    |> validate_number(:final_placement, greater_than: 0, message: "Final placement must be greater than zero")
    |> then(fn cs ->
      if get_field(cs, :claimed) == "true" and (is_nil(get_field(cs, :claimed_at))) do
        Ecto.Changeset.add_error(cs, :claimed_at, "Claimed prize must have a claimed_at timestamp")
      else
        cs
      end
    end)
    |> then(fn cs ->
      if get_field(cs, :claimed) == "true" and is_nil(get_field(cs, :claimed_at)) do
        Ecto.Changeset.add_error(cs, :claimed_at, "claimed_at is required")
      else
        cs
      end
    end)
  end

  @doc false
  def update_changeset(record, attrs) do
    record
    |> cast(attrs, [:claimed, :claimed_at, :prize_id, :player_id])
    |> validate_required([:claimed])
  end

  # ── Business operations ────────────────────────────────────────────

  def claim(_record) do
    # TODO: implement AwardedPrize.claim
    :ok
  end
end
