defmodule CardsProject.Repo.Migrations.CreateDraftSessions do
  use Ecto.Migration

  def change do
    create table(:draft_sessions) do
      add :status, :string, default: "WaitingForPlayers"
      add :draft_type, :string, default: "Booster"
      add :seats, :integer, default: 8
      add :created_at, :naive_datetime
      add :completed_at, :naive_datetime, null: true
      add :card_set_id, references(:card_sets, on_delete: :nilify_all)
      add :participants_id, references(:draft_participants, on_delete: :nilify_all)

      timestamps()
    end
    create index(:draft_sessions, [:card_set_id])
  end
end
