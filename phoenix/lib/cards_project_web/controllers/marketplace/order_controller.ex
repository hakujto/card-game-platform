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

  # POST /api/orders/{id}/process-payment
  def process_payment(conn, %{"id" => id}) do
    result = Marketplace.order_process_payment_behavior(id)
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

  # PATCH /api/orders/:id/transitions/pending-to-paid
  def transition_pending_to_paid(conn, %{"id" => id}) do
    order = Marketplace.get_order!(id)
    case Marketplace.transition_pending_to_paid_order(order) do
      {:ok, updated} ->
        json(conn, serialize_order(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/orders/:id/transitions/paid-to-processing
  def transition_paid_to_processing(conn, %{"id" => id}) do
    order = Marketplace.get_order!(id)
    case Marketplace.transition_paid_to_processing_order(order) do
      {:ok, updated} ->
        json(conn, serialize_order(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/orders/:id/transitions/processing-to-shipped
  def transition_processing_to_shipped(conn, %{"id" => id}) do
    order = Marketplace.get_order!(id)
    case Marketplace.transition_processing_to_shipped_order(order) do
      {:ok, updated} ->
        json(conn, serialize_order(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/orders/:id/transitions/shipped-to-completed
  def transition_shipped_to_completed(conn, %{"id" => id}) do
    order = Marketplace.get_order!(id)
    case Marketplace.transition_shipped_to_completed_order(order) do
      {:ok, updated} ->
        json(conn, serialize_order(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/orders/:id/transitions/pending-to-cancelled
  def transition_pending_to_cancelled(conn, %{"id" => id}) do
    order = Marketplace.get_order!(id)
    case Marketplace.transition_pending_to_cancelled_order(order) do
      {:ok, updated} ->
        json(conn, serialize_order(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/orders/:id/transitions/paid-to-cancelled
  def transition_paid_to_cancelled(conn, %{"id" => id}) do
    order = Marketplace.get_order!(id)
    case Marketplace.transition_paid_to_cancelled_order(order) do
      {:ok, updated} ->
        json(conn, serialize_order(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/orders/:id/transitions/completed-to-refunded
  def transition_completed_to_refunded(conn, %{"id" => id}) do
    order = Marketplace.get_order!(id)
    case Marketplace.transition_completed_to_refunded_order(order) do
      {:ok, updated} ->
        json(conn, serialize_order(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/orders/:id/transitions/refunded-to-completed
  def transition_refunded_to_completed(conn, %{"id" => _id}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "Transition Refunded -> Completed is not allowed"})
  end

  # PATCH /api/orders/:id/transitions/completed-to-cancelled
  def transition_completed_to_cancelled(conn, %{"id" => _id}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "Transition Completed -> Cancelled is not allowed"})
  end

  defp serialize_order(%Order{} = record) do
    record
    |> Map.take([:id, :status, :total, :discount_applied, :currency, :payment_method, :payment_reference, :shipping_address, :tracking_number, :created_at, :paid_at, :shipped_at, :player_id, :items_id, :coupon_id])
    |> (fn m -> Map.put(Map.delete(m, :created_at), :created_at, Map.get(m, :created_at)) end).()
    |> (fn m -> Map.put(Map.delete(m, :paid_at), :paid_at, Map.get(m, :paid_at)) end).()
    |> (fn m -> Map.put(Map.delete(m, :shipped_at), :shipped_at, Map.get(m, :shipped_at)) end).()
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
