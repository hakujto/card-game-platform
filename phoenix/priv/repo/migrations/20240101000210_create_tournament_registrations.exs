defmodule CardsProject.Repo.Migrations.CreateTournamentRegistrations do
  use Ecto.Migration

  def change do
    create table(:tournament_registrations) do
      add :status, :string, default: "Registered"
      add :seed, :integer, null: true
      add :final_standing, :integer, null: true
      add :points_earned, :integer, default: 0
      add :registered_at, :naive_datetime
      add :tournament_id, references(:tournaments, on_delete: :delete_all)
      add :player_id, references(:players, on_delete: :restrict)
      add :deck_id, references(:decks, on_delete: :restrict)

      timestamps()
    end
    create index(:tournament_registrations, [:tournament_id])
    create index(:tournament_registrations, [:player_id])
    create index(:tournament_registrations, [:deck_id])
  end
end
