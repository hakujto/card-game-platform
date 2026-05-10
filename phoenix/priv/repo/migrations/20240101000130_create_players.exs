defmodule CardsProject.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :display_name, :string
      add :rank, :string, default: "Bronze"
      add :rating, :integer, default: 1000
      add :peak_rating, :integer, default: 1000
      add :bio, :string, null: true
      add :country_code, :string, null: true
      add :avatar_url, :string, null: true
      add :preferred_format, :string, null: true
      add :is_verified, :boolean, default: false
      add :created_at, :naive_datetime
      add :last_active_at, :naive_datetime, null: true
      add :user_id, references(:users, on_delete: :nilify_all), null: true
      add :season_stats_id, references(:player_season_statses, on_delete: :nilify_all)

      timestamps()
    end
    create index(:players, [:user_id])
    create index(:players, [:season_stats_id])
  end
end
