defmodule CardsProjectWeb.Marketplace.CouponController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Marketplace
  alias CardsProject.Marketplace.Coupon

  def index(conn, _params) do
    coupons = Marketplace.list_coupons()
    json(conn, Enum.map(coupons, &serialize_coupon/1))
  end

  def show(conn, %{"id" => id}) do
    coupon = Marketplace.get_coupon!(id)
    json(conn, serialize_coupon(coupon))
  end

  def create(conn, params) do
    case Marketplace.create_coupon(params) do
      {:ok, coupon} ->
        conn
        |> put_status(:created)
        |> json(serialize_coupon(coupon))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    coupon = Marketplace.get_coupon!(id)
    case Marketplace.update_coupon(coupon, params) do
      {:ok, coupon} ->
        json(conn, serialize_coupon(coupon))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    coupon = Marketplace.get_coupon!(id)
    Marketplace.delete_coupon(coupon)
    send_resp(conn, :no_content, "")
  end

  # POST /api/coupons/{id}/redeem
  def redeem(conn, %{"id" => id}) do
    Marketplace.coupon_redeem_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/coupons/{id}/deactivate
  def deactivate(conn, %{"id" => id}) do
    Marketplace.coupon_deactivate_behavior(id)
    send_resp(conn, :no_content, "")
  end

  defp serialize_coupon(%Coupon{} = record) do
    Map.take(record, [:id, :code, :discount_type, :discount_value, :min_order_value, :max_uses, :uses_count, :valid_from, :valid_until, :is_active])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
