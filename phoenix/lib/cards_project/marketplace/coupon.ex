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
    has_many :orders, CardsProject.Marketplace.Order, foreign_key: :coupon_id

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:code, :discount_value, :min_order_value, :uses_count, :valid_from, :valid_until, :is_active, :discount_type, :max_uses])
    |> validate_required([:code, :discount_value, :min_order_value, :uses_count, :valid_from, :valid_until, :is_active])
    |> validate_inclusion(:discount_type, ["Percent", "Fixed"])
    |> unique_constraint(:code, message: "code must be unique")
    |> then(fn cs ->
      lv = get_field(cs, :valid_from)
      fv = get_field(cs, :valid_until)
      if not is_nil(lv) and not is_nil(fv) and not (fv > lv) do
        Ecto.Changeset.add_error(cs, :valid_until, "Coupon expiry must be after its start date")
      else
        cs
      end
    end)
    |> validate_number(:discount_value, greater_than: 0, message: "Discount value must be greater than zero")
    |> then(fn cs ->
      if get_field(cs, :discount_type) == "Percent" do
        cs |> validate_number(:discount_value, greater_than_or_equal_to: 1, less_than_or_equal_to: 100, message: "Percent discount must be between 1 and 100")
      else
        cs
      end
    end)
    |> then(fn cs ->
      if not is_nil(get_field(cs, :max_uses)) and (not ((get_field(cs, :uses_count) || 0) <= get_field(cs, :max_uses))) do
        Ecto.Changeset.add_error(cs, :uses_count, "Coupon uses count cannot exceed max_uses")
      else
        cs
      end
    end)
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
