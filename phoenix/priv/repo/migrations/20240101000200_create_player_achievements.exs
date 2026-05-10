defmodule CardsProject.Repo.Migrations.CreatePlayerAchievements do
  use Ecto.Migration

  def change do
    create table(:player_achievements) do
      add :earned_at, :naive_datetime
      add :progress, :integer, default: 0
      add :is_completed, :boolean, default: false
      add :player_id, references(:players, on_delete: :nilify_all)
      add :achievement_id, references(:achievements, on_delete: :nilify_all)

      timestamps()
    end
    create index(:player_achievements, [:player_id])
    create index(:player_achievements, [:achievement_id])
  end
end
