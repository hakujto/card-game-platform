defmodule CardsProject.Repo.Migrations.CreateDraftParticipants do
  use Ecto.Migration

  def change do
    create table(:draft_participants) do
      add :seat_number, :integer
      add :joined_at, :naive_datetime
      add :session_id, references(:draft_sessions, on_delete: :delete_all), null: true
      add :player_id, references(:players, on_delete: :restrict)
      add :drafted_cards_id, references(:draft_picks, on_delete: :delete_all), null: true

      timestamps()
    end
    create index(:draft_participants, [:session_id])
    create index(:draft_participants, [:player_id])
  end
end
