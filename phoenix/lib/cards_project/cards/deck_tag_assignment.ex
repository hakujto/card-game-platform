defmodule CardsProject.Cards.DeckTagAssignment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "deck_tag_assignments" do
    belongs_to :deck, CardsProject.Cards.Deck
    belongs_to :tag, CardsProject.Cards.DeckTag

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:deck_id, :tag_id])
  end
end
