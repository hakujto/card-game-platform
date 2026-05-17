defmodule CardsProject.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :status, :string, default: "Pending"
      add :total, :decimal, default: 0
      add :discount_applied, :decimal, default: 0
      add :currency, :string, default: "USD"
      add :payment_method, :string, null: true
      add :payment_reference, :string, null: true
      add :shipping_address, :string, null: true
      add :tracking_number, :string, null: true
      add :created_at, :naive_datetime
      add :paid_at, :naive_datetime, null: true
      add :shipped_at, :naive_datetime, null: true
      add :player_id, references(:players, on_delete: :nilify_all)
      add :items_id, references(:order_items, on_delete: :nilify_all)
      add :coupon_id, references(:coupons, on_delete: :nilify_all), null: true

      timestamps()
    end
    create index(:orders, [:player_id])
    create index(:orders, [:coupon_id])
  end
end
