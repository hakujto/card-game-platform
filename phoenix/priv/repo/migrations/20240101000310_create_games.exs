defmodule CardsProject.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :game_number, :integer
      add :winner_side, :string, null: true
      add :turns_played, :integer, null: true
      add :duration_seconds, :integer, null: true
      add :ended_by, :string, null: true
      add :replay_url, :string, null: true
      add :match_id, references(:matches, on_delete: :nilify_all)
      add :winner_id, references(:players, on_delete: :nilify_all), null: true

      timestamps()
    end
    create index(:games, [:match_id])
    create index(:games, [:winner_id])
  end
end
