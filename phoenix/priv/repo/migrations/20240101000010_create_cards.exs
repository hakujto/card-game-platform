defmodule CardsProject.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :name, :string
      add :card_type, :string, default: "Creature"
      add :rarity, :string, default: "Common"
      add :mana_cost, :integer, default: 0
      add :mana_colors, :string
      add :attack, :integer, null: true
      add :defense, :integer, null: true
      add :loyalty, :integer, null: true
      add :description, :string
      add :flavor_text, :string, null: true
      add :image_url, :string, null: true
      add :artist_name, :string, null: true
      add :legal_formats, :string
      add :is_banned, :boolean, default: false
      add :is_restricted, :boolean, default: false
      add :power_level, :integer, default: 1
      add :set_id, references(:card_sets, on_delete: :nilify_all)
      add :rulings_id, references(:card_rulings, on_delete: :nilify_all), null: true
      add :abilities_id, references(:card_abilities, on_delete: :nilify_all), null: true

      timestamps()
    end
    create index(:cards, [:set_id])
    create index(:cards, [:rulings_id])
    create index(:cards, [:abilities_id])
  end
end
