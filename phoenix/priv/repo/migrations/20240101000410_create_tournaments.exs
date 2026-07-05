defmodule CardsProject.Repo.Migrations.CreateTournaments do
  use Ecto.Migration

  def change do
    create table(:tournaments) do
      add :public_id, :string
      add :name, :string
      add :description, :string, null: true
      add :status, :string, default: "Draft"
      add :bracket_data, :map, null: true
      add :format, :string, default: "Standard"
      add :tournament_type, :string, default: "Swiss"
      add :max_players, :integer
      add :entry_fee, :decimal, default: 0
      add :prize_pool, :decimal, default: 0
      add :start_time, :naive_datetime
      add :end_time, :naive_datetime, null: true
      add :is_online, :boolean, default: true
      add :location, :string, null: true
      add :rules_text, :string, null: true
      add :created_at, :naive_datetime
      add :season_id, references(:seasons, on_delete: :restrict)
      add :organizer_id, references(:players, on_delete: :restrict)
      add :registrations_id, references(:tournament_registrations, on_delete: :delete_all), null: true
      add :rounds_id, references(:tournament_rounds, on_delete: :delete_all), null: true
      add :prizes_id, references(:tournament_prizes, on_delete: :delete_all), null: true

      timestamps()
    end
    create index(:tournaments, [:season_id])
    create index(:tournaments, [:organizer_id])
    create unique_index(:tournaments, [:public_id])
  end
end
