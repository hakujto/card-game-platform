defmodule CardsProjectWeb.Marketplace.TradeBidController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Marketplace
  alias CardsProject.Marketplace.TradeBid

  def index(conn, _params) do
    trade_bids = Marketplace.list_trade_bids()
    json(conn, Enum.map(trade_bids, &serialize_trade_bid/1))
  end

  def show(conn, %{"id" => id}) do
    trade_bid = Marketplace.get_trade_bid!(id)
    json(conn, serialize_trade_bid(trade_bid))
  end

  def create(conn, params) do
    case Marketplace.create_trade_bid(params) do
      {:ok, trade_bid} ->
        conn
        |> put_status(:created)
        |> json(serialize_trade_bid(trade_bid))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    trade_bid = Marketplace.get_trade_bid!(id)
    case Marketplace.update_trade_bid(trade_bid, params) do
      {:ok, trade_bid} ->
        json(conn, serialize_trade_bid(trade_bid))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    trade_bid = Marketplace.get_trade_bid!(id)
    Marketplace.delete_trade_bid(trade_bid)
    send_resp(conn, :no_content, "")
  end

  # GET /api/bids/{id}/outbid
  def outbid_by(conn, %{"id" => id} = params) do
    new_amount = Map.get(params, "new_amount")
    result = Marketplace.trade_bid_outbid_by_behavior(id, new_amount)
    json(conn, %{result: result})
  end

  # DELETE /api/bids/{id}
  def retract(conn, %{"id" => id}) do
    Marketplace.trade_bid_retract_behavior(id)
    send_resp(conn, :no_content, "")
  end

  defp serialize_trade_bid(%TradeBid{} = record) do
    Map.take(record, [:id, :amount, :placed_at, :is_winning, :listing_id, :bidder_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
