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
    |> validate_number(:total, greater_than_or_equal_to: 0, message: "Order total must not be negative")
    |> then(fn cs ->
      lv = get_field(cs, :total)
      fv = get_field(cs, :discount_applied)
      if not is_nil(lv) and not is_nil(fv) and not (fv <= lv) do
        Ecto.Changeset.add_error(cs, :discount_applied, "Discount applied cannot exceed order total")
      else
        cs
      end
    end)
    |> then(fn cs ->
      if get_field(cs, :status) == "Paid" and (is_nil(get_field(cs, :paid_at))) do
        Ecto.Changeset.add_error(cs, :paid_at, "Paid order must have paid_at set")
      else
        cs
      end
    end)
    |> then(fn cs ->
      if get_field(cs, :status) == "Shipped" and (is_nil(get_field(cs, :tracking_number))) do
        Ecto.Changeset.add_error(cs, :tracking_number, "Shipped order must have a tracking number")
      else
        cs
      end
    end)
    |> then(fn cs ->
      if not is_nil(get_field(cs, :shipped_at)) and (get_field(cs, :status) != "Shipped") do
        Ecto.Changeset.add_error(cs, :status, "shipped_at_requires_shipped_status validation failed")
      else
        cs
      end
    end)
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

  def process_payment(_record) do
    # TODO: implement Order.process_payment
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

  # ── Lifecycle state machine ─────────────────────────────────────────
  @allowed_transitions %{
    "Pending" => ["Paid", "Cancelled"],
    "Paid" => ["Processing", "Cancelled"],
    "Processing" => ["Shipped"],
    "Shipped" => ["Completed"],
    "Completed" => ["Refunded"]
  }

  def assert_transition(%__MODULE__{status: current}, to) do
    allowed = Map.get(@allowed_transitions, current, [])
    if to in allowed do
      :ok
    else
      {:error, "Transition #{current} -> #{to} not allowed"}
    end
  end
end
