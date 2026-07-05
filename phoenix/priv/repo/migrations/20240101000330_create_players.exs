defmodule CardsProject.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :public_id, :string
      add :display_name, :string
      add :rank, :string, default: "Bronze"
      add :rating, :integer, default: 1000
      add :peak_rating, :integer, default: 1000
      add :bio, :string, null: true
      add :country_code, :string, null: true
      add :avatar_url, :string, null: true
      add :preferred_format, :string, null: true
      add :contact_email, :string, null: true
      add :win_rate_cached, :float, null: true
      add :is_verified, :boolean, default: false
      add :created_at, :naive_datetime
      add :last_active_at, :naive_datetime, null: true
      add :user_id, references(:users, on_delete: :delete_all), null: true
      add :season_stats_id, references(:player_season_statses, on_delete: :delete_all)

      timestamps()
    end
    create unique_index(:players, [:user_id])
    create unique_index(:players, [:public_id])
    create unique_index(:players, [:display_name])
  end
end
