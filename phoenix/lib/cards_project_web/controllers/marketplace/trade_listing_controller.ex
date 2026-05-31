defmodule CardsProjectWeb.Marketplace.TradeListingController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Marketplace
  alias CardsProject.Marketplace.TradeListing

  def index(conn, params) do
    q = Map.get(params, "q")
    trade_listings = Marketplace.list_trade_listings(q)
    json(conn, Enum.map(trade_listings, &serialize_trade_listing/1))
  end

  def show(conn, %{"id" => id}) do
    trade_listing = Marketplace.get_trade_listing!(id)
    json(conn, serialize_trade_listing(trade_listing))
  end

  def create(conn, params) do
    case Marketplace.create_trade_listing(params) do
      {:ok, trade_listing} ->
        conn
        |> put_status(:created)
        |> json(serialize_trade_listing(trade_listing))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    trade_listing = Marketplace.get_trade_listing!(id)
    case Marketplace.update_trade_listing(trade_listing, params) do
      {:ok, trade_listing} ->
        json(conn, serialize_trade_listing(trade_listing))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  # POST /api/trade-listings/{id}/close
  def close(conn, %{"id" => id}) do
    Marketplace.trade_listing_close_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # PATCH /api/trade-listings/{id}/extend
  def extend(conn, %{"id" => id} = params) do
    days = Map.get(params, "days")
    Marketplace.trade_listing_extend_behavior(id, days)
    send_resp(conn, :no_content, "")
  end

  # DELETE /api/trade-listings/{id}/cancel
  def cancel(conn, %{"id" => id}) do
    Marketplace.trade_listing_cancel_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # GET /api/trade-listings/{id}/expired
  def is_expired(conn, %{"id" => id}) do
    result = Marketplace.trade_listing_is_expired_behavior(id)
    json(conn, %{result: result})
  end

  # POST /api/trade-listings/{id}/finalize
  def finalize_auction(conn, %{"id" => id}) do
    Marketplace.trade_listing_finalize_auction_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # PATCH /api/trade_listings/:id/transitions/pending-to-active
  def transition_pending_to_active(conn, %{"id" => id}) do
    trade_listing = Marketplace.get_trade_listing!(id)
    case Marketplace.transition_pending_to_active_trade_listing(trade_listing) do
      {:ok, updated} ->
        json(conn, serialize_trade_listing(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/trade_listings/:id/transitions/active-to-sold
  def transition_active_to_sold(conn, %{"id" => id}) do
    trade_listing = Marketplace.get_trade_listing!(id)
    case Marketplace.transition_active_to_sold_trade_listing(trade_listing) do
      {:ok, updated} ->
        json(conn, serialize_trade_listing(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/trade_listings/:id/transitions/active-to-expired
  def transition_active_to_expired(conn, %{"id" => id}) do
    trade_listing = Marketplace.get_trade_listing!(id)
    case Marketplace.transition_active_to_expired_trade_listing(trade_listing) do
      {:ok, updated} ->
        json(conn, serialize_trade_listing(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/trade_listings/:id/transitions/active-to-cancelled
  def transition_active_to_cancelled(conn, %{"id" => id}) do
    trade_listing = Marketplace.get_trade_listing!(id)
    case Marketplace.transition_active_to_cancelled_trade_listing(trade_listing) do
      {:ok, updated} ->
        json(conn, serialize_trade_listing(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/trade_listings/:id/transitions/sold-to-active
  def transition_sold_to_active(conn, %{"id" => _id}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "Transition Sold -> Active is not allowed"})
  end

  # PATCH /api/trade_listings/:id/transitions/expired-to-active
  def transition_expired_to_active(conn, %{"id" => _id}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "Transition Expired -> Active is not allowed"})
  end

  defp serialize_trade_listing(%TradeListing{} = record) do
    record
    |> Map.take([:id, :status, :listing_type, :asking_price, :auction_start_price, :auction_current_bid, :auction_end_time, :foil, :condition, :quantity, :description, :created_at, :expires_at, :seller_id, :card_id, :bids_id])
    |> (fn m -> Map.put(Map.delete(m, :created_at), :created_at, Map.get(m, :created_at)) end).()
    |> (fn m -> Map.put(Map.delete(m, :expires_at), :expires_at, Map.get(m, :expires_at)) end).()
    |> (fn m -> Map.put(Map.delete(m, :auction_end_time), :auction_end_time, Map.get(m, :auction_end_time)) end).()
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
