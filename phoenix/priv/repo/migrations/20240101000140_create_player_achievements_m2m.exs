defmodule CardsProject.Repo.Migrations.CreatePlayerAchievementsM2m do
  use Ecto.Migration

  def change do
    create table(:player_achievements_m2m, primary_key: false) do
      add :left_id, references(:players, on_delete: :delete_all), null: false
      add :right_id, references(:achievements, on_delete: :delete_all), null: false
    end

    create unique_index(:player_achievements_m2m, [:left_id, :right_id])
  end
end
