defmodule CardsProject.Content.DraftParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "draft_participants" do
    field :seat_number, :integer
    field :joined_at, :naive_datetime
    belongs_to :session, CardsProject.Content.DraftSession
    belongs_to :player, CardsProject.Players.Player
    belongs_to :drafted_cards, CardsProject.Content.DraftPick

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:seat_number, :joined_at, :session_id, :player_id])
    |> validate_required([:seat_number, :joined_at])
  end

  # ── Business operations ────────────────────────────────────────────

  def pick_card(_record, _card_id, _pack_number) do
    # TODO: implement DraftParticipant.pick_card
    :ok
  end

  def drafted_card_count(_record) do
    # TODO: implement DraftParticipant.drafted_card_count
    {:error, :not_implemented}
  end
end
