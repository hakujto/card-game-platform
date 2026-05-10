defmodule CardsProject.Repo.Migrations.CreateDeckCardsM2m do
  use Ecto.Migration

  def change do
    create table(:deck_cards_m2m, primary_key: false) do
      add :left_id, references(:decks, on_delete: :delete_all), null: false
      add :right_id, references(:cards, on_delete: :delete_all), null: false
    end

    create unique_index(:deck_cards_m2m, [:left_id, :right_id])
  end
end
