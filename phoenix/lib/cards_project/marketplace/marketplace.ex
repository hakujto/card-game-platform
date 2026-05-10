defmodule CardsProject.Marketplace do
  @moduledoc """
  The Marketplace BC context.
  """

  import Ecto.Query, warn: false
  alias CardsProject.Repo

  alias CardsProject.Marketplace.Product
  alias CardsProject.Marketplace.Order
  alias CardsProject.Marketplace.OrderItem
  alias CardsProject.Marketplace.Coupon
  alias CardsProject.Marketplace.Tradelisting
  alias CardsProject.Marketplace.TradeBid
  alias CardsProject.Marketplace.TradeTransaction
  alias CardsProject.Marketplace.CardPriceHistory
  alias CardsProject.Marketplace.TradeDispute

  # ── Product ─────────────────────────────────────────────────────

  def list_products, do: Repo.all(Product)

  def get_product!(id), do: Repo.get!(Product, id)

  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  def delete_product(%Product{} = product), do: Repo.delete(product)

  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  # ── Order ─────────────────────────────────────────────────────

  def list_orders, do: Repo.all(Order)

  def get_order!(id), do: Repo.get!(Order, id)

  def create_order(attrs \\ %{}) do
    %Order{}
    |> Order.changeset(attrs)
    |> Repo.insert()
  end

  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  def delete_order(%Order{} = order), do: Repo.delete(order)

  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end

  # ── OrderItem ─────────────────────────────────────────────────────

  def list_order_items, do: Repo.all(OrderItem)

  def get_order_item!(id), do: Repo.get!(OrderItem, id)

  def create_order_item(attrs \\ %{}) do
    %OrderItem{}
    |> OrderItem.changeset(attrs)
    |> Repo.insert()
  end

  def update_order_item(%OrderItem{} = order_item, attrs) do
    order_item
    |> OrderItem.changeset(attrs)
    |> Repo.update()
  end

  def delete_order_item(%OrderItem{} = order_item), do: Repo.delete(order_item)

  def change_order_item(%OrderItem{} = order_item, attrs \\ %{}) do
    OrderItem.changeset(order_item, attrs)
  end

  # ── Coupon ─────────────────────────────────────────────────────

  def list_coupons, do: Repo.all(Coupon)

  def get_coupon!(id), do: Repo.get!(Coupon, id)

  def create_coupon(attrs \\ %{}) do
    %Coupon{}
    |> Coupon.changeset(attrs)
    |> Repo.insert()
  end

  def update_coupon(%Coupon{} = coupon, attrs) do
    coupon
    |> Coupon.changeset(attrs)
    |> Repo.update()
  end

  def delete_coupon(%Coupon{} = coupon), do: Repo.delete(coupon)

  def change_coupon(%Coupon{} = coupon, attrs \\ %{}) do
    Coupon.changeset(coupon, attrs)
  end

  # ── Tradelisting ─────────────────────────────────────────────────────

  def list_tradelistings, do: Repo.all(Tradelisting)

  def get_tradelisting!(id), do: Repo.get!(Tradelisting, id)

  def create_tradelisting(attrs \\ %{}) do
    %Tradelisting{}
    |> Tradelisting.changeset(attrs)
    |> Repo.insert()
  end

  def update_tradelisting(%Tradelisting{} = tradelisting, attrs) do
    tradelisting
    |> Tradelisting.changeset(attrs)
    |> Repo.update()
  end

  def delete_tradelisting(%Tradelisting{} = tradelisting), do: Repo.delete(tradelisting)

  def change_tradelisting(%Tradelisting{} = tradelisting, attrs \\ %{}) do
    Tradelisting.changeset(tradelisting, attrs)
  end

  # ── TradeBid ─────────────────────────────────────────────────────

  def list_trade_bids, do: Repo.all(TradeBid)

  def get_trade_bid!(id), do: Repo.get!(TradeBid, id)

  def create_trade_bid(attrs \\ %{}) do
    %TradeBid{}
    |> TradeBid.changeset(attrs)
    |> Repo.insert()
  end

  def update_trade_bid(%TradeBid{} = trade_bid, attrs) do
    trade_bid
    |> TradeBid.changeset(attrs)
    |> Repo.update()
  end

  def delete_trade_bid(%TradeBid{} = trade_bid), do: Repo.delete(trade_bid)

  def change_trade_bid(%TradeBid{} = trade_bid, attrs \\ %{}) do
    TradeBid.changeset(trade_bid, attrs)
  end

  # ── TradeTransaction ─────────────────────────────────────────────────────

  def list_trade_transactions, do: Repo.all(TradeTransaction)

  def get_trade_transaction!(id), do: Repo.get!(TradeTransaction, id)

  def create_trade_transaction(attrs \\ %{}) do
    %TradeTransaction{}
    |> TradeTransaction.changeset(attrs)
    |> Repo.insert()
  end

  def update_trade_transaction(%TradeTransaction{} = trade_transaction, attrs) do
    trade_transaction
    |> TradeTransaction.changeset(attrs)
    |> Repo.update()
  end

  def delete_trade_transaction(%TradeTransaction{} = trade_transaction), do: Repo.delete(trade_transaction)

  def change_trade_transaction(%TradeTransaction{} = trade_transaction, attrs \\ %{}) do
    TradeTransaction.changeset(trade_transaction, attrs)
  end

  # ── CardPriceHistory ─────────────────────────────────────────────────────

  def list_card_price_histories, do: Repo.all(CardPriceHistory)

  def get_card_price_history!(id), do: Repo.get!(CardPriceHistory, id)

  def create_card_price_history(attrs \\ %{}) do
    %CardPriceHistory{}
    |> CardPriceHistory.changeset(attrs)
    |> Repo.insert()
  end

  def update_card_price_history(%CardPriceHistory{} = card_price_history, attrs) do
    card_price_history
    |> CardPriceHistory.changeset(attrs)
    |> Repo.update()
  end

  def delete_card_price_history(%CardPriceHistory{} = card_price_history), do: Repo.delete(card_price_history)

  def change_card_price_history(%CardPriceHistory{} = card_price_history, attrs \\ %{}) do
    CardPriceHistory.changeset(card_price_history, attrs)
  end

  # ── TradeDispute ─────────────────────────────────────────────────────

  def list_trade_disputes, do: Repo.all(TradeDispute)

  def get_trade_dispute!(id), do: Repo.get!(TradeDispute, id)

  def create_trade_dispute(attrs \\ %{}) do
    %TradeDispute{}
    |> TradeDispute.changeset(attrs)
    |> Repo.insert()
  end

  def update_trade_dispute(%TradeDispute{} = trade_dispute, attrs) do
    trade_dispute
    |> TradeDispute.changeset(attrs)
    |> Repo.update()
  end

  def delete_trade_dispute(%TradeDispute{} = trade_dispute), do: Repo.delete(trade_dispute)

  def change_trade_dispute(%TradeDispute{} = trade_dispute, attrs \\ %{}) do
    TradeDispute.changeset(trade_dispute, attrs)
  end

end
