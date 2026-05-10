defmodule CardsProject.Repo.Migrations.CreateTournamentRounds do
  use Ecto.Migration

  def change do
    create table(:tournament_rounds) do
      add :round_number, :integer
      add :status, :string, default: "Pending"
      add :started_at, :naive_datetime, null: true
      add :ended_at, :naive_datetime, null: true
      add :time_limit_minutes, :integer, default: 50
      add :tournament_id, references(:tournaments, on_delete: :nilify_all)
      add :matches_id, references(:matches, on_delete: :nilify_all)

      timestamps()
    end
    create index(:tournament_rounds, [:tournament_id])
    create index(:tournament_rounds, [:matches_id])
  end
end
