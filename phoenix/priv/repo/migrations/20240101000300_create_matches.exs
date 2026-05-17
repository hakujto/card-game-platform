defmodule CardsProject.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :table_number, :integer, null: true
      add :status, :string, default: "Pending"
      add :player1_wins, :integer, default: 0
      add :player2_wins, :integer, default: 0
      add :started_at, :naive_datetime, null: true
      add :ended_at, :naive_datetime, null: true
      add :result_notes, :string, null: true
      add :round_id, references(:tournament_rounds, on_delete: :nilify_all), null: true
      add :player1_id, references(:players, on_delete: :nilify_all)
      add :player2_id, references(:players, on_delete: :nilify_all), null: true
      add :games_id, references(:games, on_delete: :nilify_all), null: true

      timestamps()
    end
    create index(:matches, [:round_id])
    create index(:matches, [:player1_id])
    create index(:matches, [:player2_id])
  end
end
