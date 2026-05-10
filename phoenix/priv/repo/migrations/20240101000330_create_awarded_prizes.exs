defmodule CardsProject.Repo.Migrations.CreateAwardedPrizes do
  use Ecto.Migration

  def change do
    create table(:awarded_prizes) do
      add :final_placement, :integer
      add :awarded_at, :naive_datetime
      add :claimed, :boolean, default: false
      add :claimed_at, :naive_datetime, null: true
      add :prize_id, references(:tournament_prizes, on_delete: :nilify_all)
      add :player_id, references(:players, on_delete: :nilify_all)

      timestamps()
    end
    create index(:awarded_prizes, [:prize_id])
    create index(:awarded_prizes, [:player_id])
  end
end
