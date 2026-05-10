defmodule CardsProject.Repo.Migrations.CreateDeckCards do
  use Ecto.Migration

  def change do
    create table(:deck_cards) do
      add :quantity, :integer, default: 1
      add :is_commander, :boolean, default: false
      add :deck_id, references(:decks, on_delete: :nilify_all)
      add :card_id, references(:cards, on_delete: :nilify_all)

      timestamps()
    end
    create index(:deck_cards, [:deck_id])
    create index(:deck_cards, [:card_id])
  end
end
