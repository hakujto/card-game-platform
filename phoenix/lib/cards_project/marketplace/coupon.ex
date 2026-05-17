defmodule CardsProject.Marketplace.Coupon do
  use Ecto.Schema
  import Ecto.Changeset

  schema "coupons" do
    field :code, :string
    field :discount_type, :string
    field :discount_value, :decimal
    field :min_order_value, :decimal
    field :max_uses, :integer
    field :uses_count, :integer, default: 0
    field :valid_from, :naive_datetime
    field :valid_until, :naive_datetime
    field :is_active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:code, :discount_value, :min_order_value, :uses_count, :valid_from, :valid_until, :is_active, :discount_type, :max_uses])
    |> validate_required([:code, :discount_value, :min_order_value, :uses_count, :valid_from, :valid_until, :is_active])
    |> validate_inclusion(:discount_type, ["Percent", "Fixed"])
  end

  # ── Business operations ────────────────────────────────────────────

  def is_valid(_record) do
    # TODO: implement Coupon.is_valid
    {:error, :not_implemented}
  end

  def is_applicable_to_order(_record, _order_total) do
    # TODO: implement Coupon.is_applicable_to_order
    {:error, :not_implemented}
  end

  def redeem(_record) do
    # TODO: implement Coupon.redeem
    :ok
  end

  def deactivate(_record) do
    # TODO: implement Coupon.deactivate
    :ok
  end
end
