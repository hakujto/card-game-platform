defmodule CardsProject.Repo.Migrations.CreateOrderItems do
  use Ecto.Migration

  def change do
    create table(:order_items) do
      add :quantity, :integer
      add :price_at_purchase, :decimal
      add :foil, :boolean, default: false
      add :order_id, references(:orders, on_delete: :nilify_all), null: true
      add :product_id, references(:products, on_delete: :nilify_all)

      timestamps()
    end
    create index(:order_items, [:order_id])
    create index(:order_items, [:product_id])
  end
end
