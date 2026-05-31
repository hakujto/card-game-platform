defmodule CardsProject.Content.DraftPick do
  use Ecto.Schema
  import Ecto.Changeset

  schema "draft_picks" do
    field :pick_number, :integer
    field :pack_number, :integer
    field :picked_at, :naive_datetime
    belongs_to :participant, CardsProject.Content.DraftParticipant
    belongs_to :card, CardsProject.Cards.Card

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:pick_number, :pack_number, :picked_at, :participant_id, :card_id])
    |> validate_required([:pick_number, :pack_number, :picked_at])
    |> validate_number(:pick_number, greater_than: 0, message: "Pick number must be greater than zero")
    |> validate_number(:pack_number, greater_than_or_equal_to: 1, less_than_or_equal_to: 3, message: "Pack number must be between 1 and 3")
  end

  # ── Business operations ────────────────────────────────────────────

  def is_first_pick(_record) do
    # TODO: implement DraftPick.is_first_pick
    {:error, :not_implemented}
  end
end
