defmodule CardsProject.Cards.DeckSideboardCard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "deck_sideboard_cards" do
    field :quantity, :integer, default: 1
    belongs_to :deck, CardsProject.Cards.Deck
    belongs_to :card, CardsProject.Cards.Card

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:quantity, :deck_id, :card_id])
    |> validate_required([:quantity])
  end
end
