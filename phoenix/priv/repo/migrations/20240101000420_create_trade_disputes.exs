defmodule CardsProject.Repo.Migrations.CreateTradeDisputes do
  use Ecto.Migration

  def change do
    create table(:trade_disputes) do
      add :reason, :string
      add :description, :string
      add :status, :string, default: "Open"
      add :resolution, :string, null: true
      add :opened_at, :naive_datetime
      add :resolved_at, :naive_datetime, null: true
      add :transaction_id, references(:trade_transactions, on_delete: :nilify_all)
      add :opened_by_id, references(:players, on_delete: :nilify_all)
      add :resolved_by_id, references(:players, on_delete: :nilify_all), null: true

      timestamps()
    end
    create index(:trade_disputes, [:transaction_id])
    create index(:trade_disputes, [:opened_by_id])
    create index(:trade_disputes, [:resolved_by_id])
  end
end
