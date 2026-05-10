defmodule CardsProject.Repo.Migrations.CreateTournaments do
  use Ecto.Migration

  def change do
    create table(:tournaments) do
      add :name, :string
      add :description, :string, null: true
      add :format, :string, default: "Standard"
      add :tournament_type, :string, default: "Swiss"
      add :status, :string, default: "Draft"
      add :max_players, :integer
      add :entry_fee, :decimal, default: 0
      add :prize_pool, :decimal, default: 0
      add :start_time, :naive_datetime
      add :end_time, :naive_datetime, null: true
      add :is_online, :boolean, default: true
      add :location, :string, null: true
      add :rules_text, :string, null: true
      add :created_at, :naive_datetime
      add :season_id, references(:seasons, on_delete: :nilify_all)
      add :organizer_id, references(:players, on_delete: :nilify_all)
      add :registrations_id, references(:tournament_registrations, on_delete: :nilify_all), null: true
      add :rounds_id, references(:tournament_rounds, on_delete: :nilify_all), null: true
      add :prizes_id, references(:tournament_prizes, on_delete: :nilify_all), null: true

      timestamps()
    end
    create index(:tournaments, [:season_id])
    create index(:tournaments, [:organizer_id])
    create index(:tournaments, [:registrations_id])
    create index(:tournaments, [:rounds_id])
    create index(:tournaments, [:prizes_id])
  end
end
