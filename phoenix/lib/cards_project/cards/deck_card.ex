defmodule CardsProject.Cards.DeckCard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "deck_cards" do
    field :quantity, :integer, default: 1
    field :is_commander, :boolean, default: false
    belongs_to :deck, CardsProject.Cards.Deck
    belongs_to :card, CardsProject.Cards.Card

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:quantity, :is_commander, :deck_id, :card_id])
    |> validate_required([:quantity, :is_commander])
  end
end
