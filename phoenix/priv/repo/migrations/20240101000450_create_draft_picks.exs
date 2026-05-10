defmodule CardsProject.Repo.Migrations.CreateDraftPicks do
  use Ecto.Migration

  def change do
    create table(:draft_picks) do
      add :pick_number, :integer
      add :pack_number, :integer
      add :picked_at, :naive_datetime
      add :participant_id, references(:draft_participants, on_delete: :nilify_all)
      add :card_id, references(:cards, on_delete: :nilify_all)

      timestamps()
    end
    create index(:draft_picks, [:participant_id])
    create index(:draft_picks, [:card_id])
  end
end
