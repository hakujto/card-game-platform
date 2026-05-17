defmodule CardsProjectWeb.Marketplace.TradeTransactionController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Marketplace
  alias CardsProject.Marketplace.TradeTransaction

  def index(conn, _params) do
    trade_transactions = Marketplace.list_trade_transactions()
    json(conn, Enum.map(trade_transactions, &serialize_trade_transaction/1))
  end

  def show(conn, %{"id" => id}) do
    trade_transaction = Marketplace.get_trade_transaction!(id)
    json(conn, serialize_trade_transaction(trade_transaction))
  end

  def create(conn, params) do
    case Marketplace.create_trade_transaction(params) do
      {:ok, trade_transaction} ->
        conn
        |> put_status(:created)
        |> json(serialize_trade_transaction(trade_transaction))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    trade_transaction = Marketplace.get_trade_transaction!(id)
    case Marketplace.update_trade_transaction(trade_transaction, params) do
      {:ok, trade_transaction} ->
        json(conn, serialize_trade_transaction(trade_transaction))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    trade_transaction = Marketplace.get_trade_transaction!(id)
    Marketplace.delete_trade_transaction(trade_transaction)
    send_resp(conn, :no_content, "")
  end

  # POST /api/transactions/{id}/complete
  def complete(conn, %{"id" => id}) do
    Marketplace.trade_transaction_complete_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/transactions/{id}/refund
  def refund(conn, %{"id" => id}) do
    Marketplace.trade_transaction_refund_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/transactions/{id}/dispute
  def open_dispute(conn, %{"id" => id} = params) do
    reason = Map.get(params, "reason")
    Marketplace.trade_transaction_open_dispute_behavior(id, reason)
    send_resp(conn, :no_content, "")
  end

  defp serialize_trade_transaction(%TradeTransaction{} = record) do
    Map.take(record, [:id, :final_price, :platform_fee, :status, :completed_at, :listing_id, :buyer_id, :seller_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
