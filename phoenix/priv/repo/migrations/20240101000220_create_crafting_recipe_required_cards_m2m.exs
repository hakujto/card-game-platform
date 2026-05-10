defmodule CardsProject.Repo.Migrations.CreateCraftingRecipeRequiredCardsM2m do
  use Ecto.Migration

  def change do
    create table(:crafting_recipe_required_cards_m2m, primary_key: false) do
      add :left_id, references(:crafting_recipes, on_delete: :delete_all), null: false
      add :right_id, references(:cards, on_delete: :delete_all), null: false
    end

    create unique_index(:crafting_recipe_required_cards_m2m, [:left_id, :right_id])
  end
end
