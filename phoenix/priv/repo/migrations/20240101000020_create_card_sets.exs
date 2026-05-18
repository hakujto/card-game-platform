defmodule CardsProject.Repo.Migrations.CreateCardSets do
  use Ecto.Migration

  def change do
    create table(:card_sets) do
      add :name, :string
      add :code, :string
      add :release_date, :date
      add :rotation_date, :date, null: true
      add :set_type, :string, default: "Expansion"
      add :total_cards, :integer
      add :is_rotated, :boolean, default: false
      add :description, :string, null: true
      add :logo_url, :string, null: true

      timestamps()
    end
  end
end
