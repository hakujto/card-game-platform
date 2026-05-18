defmodule CardsProject.Repo.Migrations.CreateTradeListings do
  use Ecto.Migration

  def change do
    create table(:trade_listings) do
      add :listing_type, :string, default: "FixedPrice"
      add :asking_price, :decimal, null: true
      add :auction_start_price, :decimal, null: true
      add :auction_current_bid, :decimal, null: true
      add :auction_end_time, :naive_datetime, null: true
      add :foil, :boolean, default: false
      add :condition, :string, default: "Mint"
      add :quantity, :integer, default: 1
      add :status, :string, default: "Active"
      add :description, :string, null: true
      add :created_at, :naive_datetime
      add :expires_at, :naive_datetime, null: true
      add :seller_id, references(:players, on_delete: :nilify_all)
      add :card_id, references(:cards, on_delete: :nilify_all)
      add :bids_id, references(:trade_bids, on_delete: :nilify_all), null: true

      timestamps()
    end
    create index(:trade_listings, [:seller_id])
    create index(:trade_listings, [:card_id])
  end
end
