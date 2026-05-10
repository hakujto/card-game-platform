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
  end
end
