defmodule CardsProjectWeb.Marketplace.OrderItemController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Marketplace
  alias CardsProject.Marketplace.OrderItem

  def index(conn, _params) do
    order_items = Marketplace.list_order_items()
    json(conn, Enum.map(order_items, &serialize_order_item/1))
  end

  def show(conn, %{"id" => id}) do
    order_item = Marketplace.get_order_item!(id)
    json(conn, serialize_order_item(order_item))
  end

  def create(conn, params) do
    case Marketplace.create_order_item(params) do
      {:ok, order_item} ->
        conn
        |> put_status(:created)
        |> json(serialize_order_item(order_item))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    order_item = Marketplace.get_order_item!(id)
    case Marketplace.update_order_item(order_item, params) do
      {:ok, order_item} ->
        json(conn, serialize_order_item(order_item))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    order_item = Marketplace.get_order_item!(id)
    Marketplace.delete_order_item(order_item)
    send_resp(conn, :no_content, "")
  end

  # GET /api/order-items/{id}/total
  def line_total(conn, %{"id" => id}) do
    result = Marketplace.order_item_line_total_behavior(id)
    json(conn, %{result: result})
  end

  defp serialize_order_item(%OrderItem{} = record) do
    Map.take(record, [:id, :quantity, :price_at_purchase, :foil, :order_id, :product_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
