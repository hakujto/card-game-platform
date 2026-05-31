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
    |> validate_number(:quantity, greater_than: 0, message: "Order item quantity must be greater than zero")
    |> validate_number(:price_at_purchase, greater_than_or_equal_to: 0, message: "Price at purchase must not be negative")
  end

  # ── Business operations ────────────────────────────────────────────

  def line_total(_record) do
    # TODO: implement OrderItem.line_total
    {:error, :not_implemented}
  end
end
