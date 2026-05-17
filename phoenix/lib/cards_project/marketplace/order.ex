defmodule CardsProject.Marketplace.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :status, :string
    field :total, :decimal
    field :discount_applied, :decimal
    field :currency, :string, default: "USD"
    field :payment_method, :string
    field :payment_reference, :string
    field :shipping_address, :string
    field :tracking_number, :string
    field :created_at, :naive_datetime
    field :paid_at, :naive_datetime
    field :shipped_at, :naive_datetime
    belongs_to :player, CardsProject.Players.Player
    belongs_to :items, CardsProject.Marketplace.OrderItem
    belongs_to :coupon, CardsProject.Marketplace.Coupon

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:total, :discount_applied, :currency, :created_at, :status, :payment_method, :payment_reference, :shipping_address, :tracking_number, :paid_at, :shipped_at, :player_id, :coupon_id])
    |> validate_required([:total, :discount_applied, :currency, :created_at])
    |> validate_inclusion(:status, ["Pending", "Paid", "Processing", "Shipped", "Completed", "Cancelled", "Refunded"])
    |> validate_inclusion(:payment_method, ["Card", "PayPal", "Crypto", "PlatformCredits"])
  end

  # ── Business operations ────────────────────────────────────────────

  def cancel(_record) do
    # TODO: implement Order.cancel
    :ok
  end

  def pay(_record, _payment_ref) do
    # TODO: implement Order.pay
    {:error, :not_implemented}
  end

  def calculate_total(_record) do
    # TODO: implement Order.calculate_total
    {:error, :not_implemented}
  end

  def apply_discount(_record, _percent) do
    # TODO: implement Order.apply_discount
    {:error, :not_implemented}
  end

  def refund(_record) do
    # TODO: implement Order.refund
    :ok
  end

  def notify_shipped(_record) do
    # TODO: implement Order.notify_shipped
    :ok
  end
end
