defmodule CardsProjectWeb.Marketplace.OrderController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Marketplace
  alias CardsProject.Marketplace.Order

  def index(conn, _params) do
    orders = Marketplace.list_orders()
    json(conn, Enum.map(orders, &serialize_order/1))
  end

  def show(conn, %{"id" => id}) do
    order = Marketplace.get_order!(id)
    json(conn, serialize_order(order))
  end

  def create(conn, params) do
    case Marketplace.create_order(params) do
      {:ok, order} ->
        conn
        |> put_status(:created)
        |> json(serialize_order(order))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    order = Marketplace.get_order!(id)
    case Marketplace.update_order(order, params) do
      {:ok, order} ->
        json(conn, serialize_order(order))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    order = Marketplace.get_order!(id)
    Marketplace.delete_order(order)
    send_resp(conn, :no_content, "")
  end

  # DELETE /api/orders/{id}/cancel
  def cancel(conn, %{"id" => id}) do
    Marketplace.order_cancel_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/orders/{id}/pay
  def pay(conn, %{"id" => id} = params) do
    payment_ref = Map.get(params, "payment_ref")
    result = Marketplace.order_pay_behavior(id, payment_ref)
    json(conn, %{result: result})
  end

  # GET /api/orders/{id}/total
  def calculate_total(conn, %{"id" => id}) do
    result = Marketplace.order_calculate_total_behavior(id)
    json(conn, %{result: result})
  end

  # PATCH /api/orders/{id}/discount
  def apply_discount(conn, %{"id" => id} = params) do
    percent = Map.get(params, "percent")
    result = Marketplace.order_apply_discount_behavior(id, percent)
    json(conn, %{result: result})
  end

  # POST /api/orders/{id}/refund
  def refund(conn, %{"id" => id}) do
    Marketplace.order_refund_behavior(id)
    send_resp(conn, :no_content, "")
  end

  defp serialize_order(%Order{} = record) do
    Map.take(record, [:id, :status, :total, :discount_applied, :currency, :payment_method, :payment_reference, :shipping_address, :tracking_number, :created_at, :paid_at, :shipped_at, :player_id, :items_id, :coupon_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
