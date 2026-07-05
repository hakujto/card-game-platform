defmodule CardsProject.Repo.Migrations.CreateTournamentJudges do
  use Ecto.Migration

  def change do
    create table(:tournament_judges) do
      add :role, :string, default: "Judge"
      add :tournament_id, references(:tournaments, on_delete: :delete_all)
      add :player_id, references(:players, on_delete: :restrict)

      timestamps()
    end
    create index(:tournament_judges, [:tournament_id])
    create index(:tournament_judges, [:player_id])
  end
end
