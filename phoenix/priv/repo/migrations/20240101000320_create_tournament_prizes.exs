defmodule CardsProject.Repo.Migrations.CreateTournamentPrizes do
  use Ecto.Migration

  def change do
    create table(:tournament_prizes) do
      add :placement_from, :integer
      add :placement_to, :integer
      add :prize_type, :string
      add :amount, :decimal, default: 0
      add :description, :string, null: true
      add :packs_count, :integer, null: true
      add :season_points, :integer, default: 0
      add :tournament_id, references(:tournaments, on_delete: :nilify_all)

      timestamps()
    end
    create index(:tournament_prizes, [:tournament_id])
  end
end
