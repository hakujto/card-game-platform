defmodule CardsProject.Marketplace.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "order_items" do
    field :quantity, :integer
    field :price_at_purchase, :decimal
    field :foil, :boolean, default: false
    belongs_to :order, CardsProject.Marketplace.Order
    belongs_to :product, CardsProject.Marketplace.Product

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:quantity, :price_at_purchase, :foil, :order_id, :product_id])
    |> validate_required([:quantity, :price_at_purchase, :foil])
  end
end
