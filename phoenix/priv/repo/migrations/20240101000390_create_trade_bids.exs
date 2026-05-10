defmodule CardsProject.Repo.Migrations.CreateTradeBids do
  use Ecto.Migration

  def change do
    create table(:trade_bids) do
      add :amount, :decimal
      add :placed_at, :naive_datetime
      add :is_winning, :boolean, default: false
      add :listing_id, references(:tradelistings, on_delete: :nilify_all)
      add :bidder_id, references(:players, on_delete: :nilify_all)

      timestamps()
    end
    create index(:trade_bids, [:listing_id])
    create index(:trade_bids, [:bidder_id])
  end
end
