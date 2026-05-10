defmodule CardsProject.Repo.Migrations.CreateCraftingRecipes do
  use Ecto.Migration

  def change do
    create table(:crafting_recipes) do
      add :dust_cost, :integer
      add :is_available, :boolean, default: true
      add :result_card_id, references(:cards, on_delete: :nilify_all)

      timestamps()
    end
    create index(:crafting_recipes, [:result_card_id])
  end
end
