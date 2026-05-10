defmodule CardsProject.Players.CraftingIngredient do
  use Ecto.Schema
  import Ecto.Changeset

  schema "crafting_ingredients" do
    field :quantity, :integer, default: 1
    belongs_to :recipe, CardsProject.Players.CraftingRecipe
    belongs_to :card, CardsProject.Cards.Card

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:quantity, :recipe_id, :card_id])
    |> validate_required([:quantity])
  end
end
