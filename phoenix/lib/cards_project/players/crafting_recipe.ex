defmodule CardsProject.Players.CraftingRecipe do
  use Ecto.Schema
  import Ecto.Changeset

  schema "crafting_recipes" do
    field :dust_cost, :integer
    field :is_available, :boolean, default: true
    belongs_to :result_card, CardsProject.Cards.Card
    many_to_many :required_cards, CardsProject.Cards.Card, join_through: "crafting_recipe_required_cards_m2m"

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:dust_cost, :is_available, :result_card_id])
    |> validate_required([:dust_cost, :is_available])
  end

  # ── Business operations ────────────────────────────────────────────

  def disable(_record) do
    # TODO: implement CraftingRecipe.disable
    :ok
  end

  def enable(_record) do
    # TODO: implement CraftingRecipe.enable
    :ok
  end
end
