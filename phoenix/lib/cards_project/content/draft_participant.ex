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
    |> cast(attrs, [:seat_number, :joined_at, :session_id, :player_id, :drafted_cards_id])
    |> validate_required([:seat_number, :joined_at])
  end
end
