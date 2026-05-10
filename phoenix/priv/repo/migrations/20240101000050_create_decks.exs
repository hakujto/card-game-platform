defmodule CardsProject.Repo.Migrations.CreateDecks do
  use Ecto.Migration

  def change do
    create table(:decks) do
      add :name, :string
      add :description, :string, null: true
      add :format, :string, default: "Standard"
      add :is_public, :boolean, default: false
      add :is_tournament_legal, :boolean, default: false
      add :archetype, :string, null: true
      add :wins, :integer, default: 0
      add :losses, :integer, default: 0
      add :created_at, :naive_datetime
      add :player_id, references(:players, on_delete: :nilify_all)

      timestamps()
    end
    create index(:decks, [:player_id])
  end
end
