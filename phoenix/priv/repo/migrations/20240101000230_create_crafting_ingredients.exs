defmodule CardsProject.Repo.Migrations.CreateCraftingIngredients do
  use Ecto.Migration

  def change do
    create table(:crafting_ingredients) do
      add :quantity, :integer, default: 1
      add :recipe_id, references(:crafting_recipes, on_delete: :nilify_all)
      add :card_id, references(:cards, on_delete: :nilify_all)

      timestamps()
    end
    create index(:crafting_ingredients, [:recipe_id])
    create index(:crafting_ingredients, [:card_id])
  end
end
