defmodule CardsProject.Repo.Migrations.CreateCardAbilities do
  use Ecto.Migration

  def change do
    create table(:card_abilities) do
      add :ability_type, :string, default: "Keyword"
      add :keyword, :string, null: true
      add :ability_text, :string
      add :timing, :string, null: true
      add :card_id, references(:cards, on_delete: :nilify_all)

      timestamps()
    end
    create index(:card_abilities, [:card_id])
  end
end
