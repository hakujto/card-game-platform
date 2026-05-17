defmodule CardsProjectWeb.Marketplace.TradeDisputeController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Marketplace
  alias CardsProject.Marketplace.TradeDispute

  def index(conn, _params) do
    trade_disputes = Marketplace.list_trade_disputes()
    json(conn, Enum.map(trade_disputes, &serialize_trade_dispute/1))
  end

  def show(conn, %{"id" => id}) do
    trade_dispute = Marketplace.get_trade_dispute!(id)
    json(conn, serialize_trade_dispute(trade_dispute))
  end

  def create(conn, params) do
    case Marketplace.create_trade_dispute(params) do
      {:ok, trade_dispute} ->
        conn
        |> put_status(:created)
        |> json(serialize_trade_dispute(trade_dispute))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    trade_dispute = Marketplace.get_trade_dispute!(id)
    case Marketplace.update_trade_dispute(trade_dispute, params) do
      {:ok, trade_dispute} ->
        json(conn, serialize_trade_dispute(trade_dispute))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    trade_dispute = Marketplace.get_trade_dispute!(id)
    Marketplace.delete_trade_dispute(trade_dispute)
    send_resp(conn, :no_content, "")
  end

  # POST /api/disputes/{id}/escalate
  def escalate(conn, %{"id" => id}) do
    Marketplace.trade_dispute_escalate_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/disputes/{id}/resolve
  def resolve(conn, %{"id" => id} = params) do
    resolution_text = Map.get(params, "resolution_text")
    Marketplace.trade_dispute_resolve_behavior(id, resolution_text)
    send_resp(conn, :no_content, "")
  end

  # POST /api/disputes/{id}/review
  def review(conn, %{"id" => id}) do
    Marketplace.trade_dispute_review_behavior(id)
    send_resp(conn, :no_content, "")
  end

  defp serialize_trade_dispute(%TradeDispute{} = record) do
    Map.take(record, [:id, :reason, :description, :status, :resolution, :opened_at, :resolved_at, :transaction_id, :opened_by_id, :resolved_by_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
