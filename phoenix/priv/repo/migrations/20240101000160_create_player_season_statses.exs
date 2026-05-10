defmodule CardsProject.Repo.Migrations.CreatePlayerSeasonStatses do
  use Ecto.Migration

  def change do
    create table(:player_season_statses) do
      add :wins, :integer, default: 0
      add :losses, :integer, default: 0
      add :draws, :integer, default: 0
      add :tournament_wins, :integer, default: 0
      add :highest_rank, :string, null: true
      add :season_points, :integer, default: 0
      add :player_id, references(:players, on_delete: :nilify_all), null: true
      add :season_id, references(:seasons, on_delete: :nilify_all)

      timestamps()
    end
    create index(:player_season_statses, [:player_id])
    create index(:player_season_statses, [:season_id])
  end
end
