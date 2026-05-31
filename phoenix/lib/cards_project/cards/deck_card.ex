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
    |> validate_number(:quantity, greater_than_or_equal_to: 1, less_than_or_equal_to: 4, message: "A deck can contain between 1 and 4 copies of a card")
    |> then(fn cs ->
      if get_field(cs, :is_commander) == "true" and (get_field(cs, :quantity) != "1") do
        Ecto.Changeset.add_error(cs, :quantity, "Commander card must appear exactly once in the deck")
      else
        cs
      end
    end)
  end

  # ── Business operations ────────────────────────────────────────────

  def increment(_record, _amount) do
    # TODO: implement DeckCard.increment
    :ok
  end

  def decrement(_record, _amount) do
    # TODO: implement DeckCard.decrement
    :ok
  end
end
