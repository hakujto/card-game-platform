defmodule CardsProject.Repo.Migrations.CreateDeckSideboardCards do
  use Ecto.Migration

  def change do
    create table(:deck_sideboard_cards) do
      add :quantity, :integer, default: 1
      add :deck_id, references(:decks, on_delete: :nilify_all)
      add :card_id, references(:cards, on_delete: :nilify_all)

      timestamps()
    end
    create index(:deck_sideboard_cards, [:deck_id])
    create index(:deck_sideboard_cards, [:card_id])
  end
end
