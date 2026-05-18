defmodule CardsProject.Repo.Migrations.CreateTradeTransactions do
  use Ecto.Migration

  def change do
    create table(:trade_transactions) do
      add :final_price, :decimal
      add :platform_fee, :decimal
      add :status, :string, default: "Pending"
      add :completed_at, :naive_datetime, null: true
      add :listing_id, references(:trade_listings, on_delete: :nilify_all)
      add :buyer_id, references(:players, on_delete: :nilify_all)
      add :seller_id, references(:players, on_delete: :nilify_all)

      timestamps()
    end
    create index(:trade_transactions, [:listing_id])
    create index(:trade_transactions, [:buyer_id])
    create index(:trade_transactions, [:seller_id])
  end
end
