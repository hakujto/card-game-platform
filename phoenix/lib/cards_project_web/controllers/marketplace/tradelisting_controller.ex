defmodule CardsProjectWeb.Marketplace.TradelistingController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Marketplace
  alias CardsProject.Marketplace.Tradelisting

  def index(conn, _params) do
    tradelistings = Marketplace.list_tradelistings()
    json(conn, Enum.map(tradelistings, &serialize_tradelisting/1))
  end

  def show(conn, %{"id" => id}) do
    tradelisting = Marketplace.get_tradelisting!(id)
    json(conn, serialize_tradelisting(tradelisting))
  end

  def create(conn, params) do
    case Marketplace.create_tradelisting(params) do
      {:ok, tradelisting} ->
        conn
        |> put_status(:created)
        |> json(serialize_tradelisting(tradelisting))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    tradelisting = Marketplace.get_tradelisting!(id)
    case Marketplace.update_tradelisting(tradelisting, params) do
      {:ok, tradelisting} ->
        json(conn, serialize_tradelisting(tradelisting))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    tradelisting = Marketplace.get_tradelisting!(id)
    Marketplace.delete_tradelisting(tradelisting)
    send_resp(conn, :no_content, "")
  end

  # POST /api/trade-listings/{id}/close
  def close(conn, %{"id" => id}) do
    Marketplace.tradelisting_close_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # PATCH /api/trade-listings/{id}/extend
  def extend(conn, %{"id" => id} = params) do
    days = Map.get(params, "days")
    Marketplace.tradelisting_extend_behavior(id, days)
    send_resp(conn, :no_content, "")
  end

  # DELETE /api/trade-listings/{id}/cancel
  def cancel(conn, %{"id" => id}) do
    Marketplace.tradelisting_cancel_behavior(id)
    send_resp(conn, :no_content, "")
  end

  defp serialize_tradelisting(%Tradelisting{} = record) do
    Map.take(record, [:id, :listing_type, :asking_price, :auction_start_price, :auction_current_bid, :auction_end_time, :foil, :condition, :quantity, :status, :description, :created_at, :expires_at, :seller_id, :card_id, :bids_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
