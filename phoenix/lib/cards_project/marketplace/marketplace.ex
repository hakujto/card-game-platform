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
  alias CardsProject.Marketplace.TradeListing
  alias CardsProject.Marketplace.TradeBid
  alias CardsProject.Marketplace.TradeTransaction
  alias CardsProject.Marketplace.CardPriceHistory
  alias CardsProject.Marketplace.TradeDispute

  # ── Product ─────────────────────────────────────────────────────

  def list_products(nil), do: Repo.all(Product)
  def list_products(term) do
    Repo.all(from q in Product, where: like(fragment("lower(?)", q.name), ^("%#{String.downcase(term)}%")) or like(fragment("lower(?)", q.description), ^("%#{String.downcase(term)}%")))
  end

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

  def product_activate_behavior(id) do
    product = Repo.get!(Product, id)
    Product.activate(product)
    Repo.update!(Product.changeset(product, %{}))
  end

  def product_deactivate_behavior(id) do
    product = Repo.get!(Product, id)
    Product.deactivate(product)
    Repo.update!(Product.changeset(product, %{}))
  end

  def product_apply_discount_behavior(id, percent) do
    product = Repo.get!(Product, id)
    result = Product.apply_discount(product, percent)
    Repo.update!(Product.changeset(product, %{}))
    result
  end

  def product_restock_behavior(id, quantity) do
    product = Repo.get!(Product, id)
    Product.restock(product, quantity)
    Repo.update!(Product.changeset(product, %{}))
  end

  def product_effective_price_behavior(id) do
    product = Repo.get!(Product, id)
    result = Product.effective_price(product)
    Repo.update!(Product.changeset(product, %{}))
    result
  end

  def product_is_in_stock_behavior(id) do
    product = Repo.get!(Product, id)
    result = Product.is_in_stock(product)
    Repo.update!(Product.changeset(product, %{}))
    result
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
    case order |> Order.changeset(attrs) |> Repo.update() do
      {:ok, order} ->
        order_hook_notify_status_change(order)
        {:ok, order}
      err -> err
    end
  end

  def delete_order(%Order{} = order), do: Repo.delete(order)

  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end

  def order_cancel_behavior(id) do
    order = Repo.get!(Order, id)
    Order.cancel(order)
    Repo.update!(Order.changeset(order, %{}))
  end

  def order_pay_behavior(id, payment_ref) do
    order = Repo.get!(Order, id)
    result = Order.pay(order, payment_ref)
    Repo.update!(Order.changeset(order, %{}))
    result
  end

  def order_process_payment_behavior(id) do
    order = Repo.get!(Order, id)
    result = Order.process_payment(order)
    Repo.update!(Order.changeset(order, %{}))
    result
  end

  def order_calculate_total_behavior(id) do
    order = Repo.get!(Order, id)
    result = Order.calculate_total(order)
    Repo.update!(Order.changeset(order, %{}))
    result
  end

  def order_apply_discount_behavior(id, percent) do
    order = Repo.get!(Order, id)
    result = Order.apply_discount(order, percent)
    Repo.update!(Order.changeset(order, %{}))
    result
  end

  def order_refund_behavior(id) do
    order = Repo.get!(Order, id)
    Order.refund(order)
    Repo.update!(Order.changeset(order, %{}))
  end

  # triggered by @on(status = Shipped)
  def order_set_status(id, value) do
    order = Repo.get!(Order, id)
    order = Order.changeset(order, %{status: value})
    order = Repo.update!(order)
    if to_string(value) == "Shipped" do
      Order.notify_shipped(order)
      Repo.update!(Order.changeset(order, %{}))
    end
    :ok
  end

  def transition_pending_to_paid_order(%Order{} = order) do
    case Order.assert_transition(order, "Paid") do
      {:error, msg} -> {:error, :conflict, msg}
      :ok ->
        if is_nil(order.payment_method) do
          {:error, :unprocessable, "payment_method is required for Pending -> Paid"}
        else
          order
          |> Ecto.Changeset.change(%{status: "Paid"})
          # @after: Order.process_payment(order)
          |> Repo.update()
        end
    end
  end

  def transition_paid_to_processing_order(%Order{} = order) do
    case Order.assert_transition(order, "Processing") do
      {:error, msg} -> {:error, :conflict, msg}
      :ok ->
          order
          |> Ecto.Changeset.change(%{status: "Processing"})
          |> Repo.update()
    end
  end

  def transition_processing_to_shipped_order(%Order{} = order) do
    case Order.assert_transition(order, "Shipped") do
      {:error, msg} -> {:error, :conflict, msg}
      :ok ->
        if is_nil(order.tracking_number) do
          {:error, :unprocessable, "tracking_number is required for Processing -> Shipped"}
        else
          order
          |> Ecto.Changeset.change(%{status: "Shipped"})
          # @after: Order.notify_shipped(order)
          |> Repo.update()
        end
    end
  end

  def transition_shipped_to_completed_order(%Order{} = order) do
    case Order.assert_transition(order, "Completed") do
      {:error, msg} -> {:error, :conflict, msg}
      :ok ->
          order
          |> Ecto.Changeset.change(%{status: "Completed"})
          |> Repo.update()
    end
  end

  def transition_pending_to_cancelled_order(%Order{} = order) do
    case Order.assert_transition(order, "Cancelled") do
      {:error, msg} -> {:error, :conflict, msg}
      :ok ->
          order
          |> Ecto.Changeset.change(%{status: "Cancelled"})
          # @after: Order.cancel(order)
          |> Repo.update()
    end
  end

  def transition_paid_to_cancelled_order(%Order{} = order) do
    case Order.assert_transition(order, "Cancelled") do
      {:error, msg} -> {:error, :conflict, msg}
      :ok ->
          order
          |> Ecto.Changeset.change(%{status: "Cancelled"})
          # @after: Order.cancel(order)
          |> Repo.update()
    end
  end

  def transition_completed_to_refunded_order(%Order{} = order) do
    case Order.assert_transition(order, "Refunded") do
      {:error, msg} -> {:error, :conflict, msg}
      :ok ->
          order
          |> Ecto.Changeset.change(%{status: "Refunded"})
          # @after: Order.refund(order)
          |> Repo.update()
    end
  end

  # ── Order lifecycle hooks ─────────────────────────────────────

  defp order_hook_notify_status_change(%Order{} = order) do
    # TODO: implement notify_status_change
    order
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

  def order_item_line_total_behavior(id) do
    order_item = Repo.get!(OrderItem, id)
    result = OrderItem.line_total(order_item)
    Repo.update!(OrderItem.changeset(order_item, %{}))
    result
  end

  # ── Coupon ─────────────────────────────────────────────────────

  def list_coupons(nil), do: Repo.all(Coupon)
  def list_coupons(term) do
    Repo.all(from q in Coupon, where: like(fragment("lower(?)", q.code), ^("%#{String.downcase(term)}%")))
  end

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

  def coupon_is_valid_behavior(id) do
    coupon = Repo.get!(Coupon, id)
    result = Coupon.is_valid(coupon)
    Repo.update!(Coupon.changeset(coupon, %{}))
    result
  end

  def coupon_is_applicable_to_order_behavior(id, order_total) do
    coupon = Repo.get!(Coupon, id)
    result = Coupon.is_applicable_to_order(coupon, order_total)
    Repo.update!(Coupon.changeset(coupon, %{}))
    result
  end

  def coupon_redeem_behavior(id) do
    coupon = Repo.get!(Coupon, id)
    Coupon.redeem(coupon)
    Repo.update!(Coupon.changeset(coupon, %{}))
  end

  def coupon_deactivate_behavior(id) do
    coupon = Repo.get!(Coupon, id)
    Coupon.deactivate(coupon)
    Repo.update!(Coupon.changeset(coupon, %{}))
  end

  # ── TradeListing ─────────────────────────────────────────────────────

  def list_trade_listings(nil), do: Repo.all(TradeListing)
  def list_trade_listings(term) do
    Repo.all(from q in TradeListing, where: like(fragment("lower(?)", q.description), ^("%#{String.downcase(term)}%")))
  end

  def get_trade_listing!(id), do: Repo.get!(TradeListing, id)

  def create_trade_listing(attrs \\ %{}) do
    %TradeListing{}
    |> TradeListing.changeset(attrs)
    |> Repo.insert()
  end

  def update_trade_listing(%TradeListing{} = trade_listing, attrs) do
    trade_listing
    |> TradeListing.changeset(attrs)
    |> Repo.update()
  end

  def delete_trade_listing(%TradeListing{} = trade_listing), do: Repo.delete(trade_listing)

  def change_trade_listing(%TradeListing{} = trade_listing, attrs \\ %{}) do
    TradeListing.changeset(trade_listing, attrs)
  end

  def trade_listing_close_behavior(id) do
    trade_listing = Repo.get!(TradeListing, id)
    TradeListing.close(trade_listing)
    Repo.update!(TradeListing.changeset(trade_listing, %{}))
  end

  def trade_listing_extend_behavior(id, days) do
    trade_listing = Repo.get!(TradeListing, id)
    TradeListing.extend(trade_listing, days)
    Repo.update!(TradeListing.changeset(trade_listing, %{}))
  end

  def trade_listing_cancel_behavior(id) do
    trade_listing = Repo.get!(TradeListing, id)
    TradeListing.cancel(trade_listing)
    Repo.update!(TradeListing.changeset(trade_listing, %{}))
  end

  def trade_listing_is_expired_behavior(id) do
    trade_listing = Repo.get!(TradeListing, id)
    result = TradeListing.is_expired(trade_listing)
    Repo.update!(TradeListing.changeset(trade_listing, %{}))
    result
  end

  def trade_listing_finalize_auction_behavior(id) do
    trade_listing = Repo.get!(TradeListing, id)
    TradeListing.finalize_auction(trade_listing)
    Repo.update!(TradeListing.changeset(trade_listing, %{}))
  end

  def transition_pending_to_active_trade_listing(%TradeListing{} = trade_listing) do
    case TradeListing.assert_transition(trade_listing, "Active") do
      {:error, msg} -> {:error, :conflict, msg}
      :ok ->
        if is_nil(trade_listing.quantity) do
          {:error, :unprocessable, "quantity is required for Pending -> Active"}
        else
          trade_listing
          |> Ecto.Changeset.change(%{status: "Active"})
          |> Repo.update()
        end
    end
  end

  def transition_active_to_sold_trade_listing(%TradeListing{} = trade_listing) do
    case TradeListing.assert_transition(trade_listing, "Sold") do
      {:error, msg} -> {:error, :conflict, msg}
      :ok ->
          trade_listing
          |> Ecto.Changeset.change(%{status: "Sold"})
          # @after: TradeListing.finalize_auction(trade_listing)
          |> Repo.update()
    end
  end

  def transition_active_to_expired_trade_listing(%TradeListing{} = trade_listing) do
    case TradeListing.assert_transition(trade_listing, "Expired") do
      {:error, msg} -> {:error, :conflict, msg}
      :ok ->
          trade_listing
          |> Ecto.Changeset.change(%{status: "Expired"})
          # @after: TradeListing.close(trade_listing)
          |> Repo.update()
    end
  end

  def transition_active_to_cancelled_trade_listing(%TradeListing{} = trade_listing) do
    case TradeListing.assert_transition(trade_listing, "Cancelled") do
      {:error, msg} -> {:error, :conflict, msg}
      :ok ->
          trade_listing
          |> Ecto.Changeset.change(%{status: "Cancelled"})
          # @after: TradeListing.cancel(trade_listing)
          |> Repo.update()
    end
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

  def trade_bid_outbid_by_behavior(id, new_amount) do
    trade_bid = Repo.get!(TradeBid, id)
    result = TradeBid.outbid_by(trade_bid, new_amount)
    Repo.update!(TradeBid.changeset(trade_bid, %{}))
    result
  end

  def trade_bid_retract_behavior(id) do
    trade_bid = Repo.get!(TradeBid, id)
    TradeBid.retract(trade_bid)
    Repo.update!(TradeBid.changeset(trade_bid, %{}))
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

  def trade_transaction_complete_behavior(id) do
    trade_transaction = Repo.get!(TradeTransaction, id)
    TradeTransaction.complete(trade_transaction)
    Repo.update!(TradeTransaction.changeset(trade_transaction, %{}))
  end

  def trade_transaction_refund_behavior(id) do
    trade_transaction = Repo.get!(TradeTransaction, id)
    TradeTransaction.refund(trade_transaction)
    Repo.update!(TradeTransaction.changeset(trade_transaction, %{}))
  end

  def trade_transaction_open_dispute_behavior(id, reason) do
    trade_transaction = Repo.get!(TradeTransaction, id)
    TradeTransaction.open_dispute(trade_transaction, reason)
    Repo.update!(TradeTransaction.changeset(trade_transaction, %{}))
  end

  def trade_transaction_seller_net_behavior(id) do
    trade_transaction = Repo.get!(TradeTransaction, id)
    result = TradeTransaction.seller_net(trade_transaction)
    Repo.update!(TradeTransaction.changeset(trade_transaction, %{}))
    result
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

  def card_price_history_price_change_percent_behavior(id, previous_avg) do
    card_price_history = Repo.get!(CardPriceHistory, id)
    result = CardPriceHistory.price_change_percent(card_price_history, previous_avg)
    Repo.update!(CardPriceHistory.changeset(card_price_history, %{}))
    result
  end

  def card_price_history_is_price_spike_behavior(id, threshold_percent) do
    card_price_history = Repo.get!(CardPriceHistory, id)
    result = CardPriceHistory.is_price_spike(card_price_history, threshold_percent)
    Repo.update!(CardPriceHistory.changeset(card_price_history, %{}))
    result
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

  def trade_dispute_escalate_behavior(id) do
    trade_dispute = Repo.get!(TradeDispute, id)
    TradeDispute.escalate(trade_dispute)
    Repo.update!(TradeDispute.changeset(trade_dispute, %{}))
  end

  def trade_dispute_resolve_behavior(id, resolution_text) do
    trade_dispute = Repo.get!(TradeDispute, id)
    TradeDispute.resolve(trade_dispute, resolution_text)
    Repo.update!(TradeDispute.changeset(trade_dispute, %{}))
  end

  def trade_dispute_close_resolved_behavior(id) do
    trade_dispute = Repo.get!(TradeDispute, id)
    TradeDispute.close_resolved(trade_dispute)
    Repo.update!(TradeDispute.changeset(trade_dispute, %{}))
  end

  def trade_dispute_review_behavior(id) do
    trade_dispute = Repo.get!(TradeDispute, id)
    TradeDispute.review(trade_dispute)
    Repo.update!(TradeDispute.changeset(trade_dispute, %{}))
  end

  def transition_open_to_under_review_trade_dispute(%TradeDispute{} = trade_dispute) do
    case TradeDispute.assert_transition(trade_dispute, "UnderReview") do
      {:error, msg} -> {:error, :conflict, msg}
      :ok ->
          trade_dispute
          |> Ecto.Changeset.change(%{status: "UnderReview"})
          # @after: TradeDispute.review(trade_dispute)
          |> Repo.update()
    end
  end

  def transition_under_review_to_resolved_trade_dispute(%TradeDispute{} = trade_dispute) do
    case TradeDispute.assert_transition(trade_dispute, "Resolved") do
      {:error, msg} -> {:error, :conflict, msg}
      :ok ->
        if is_nil(trade_dispute.resolution) do
          {:error, :unprocessable, "resolution is required for UnderReview -> Resolved"}
        else
          trade_dispute
          |> Ecto.Changeset.change(%{status: "Resolved"})
          # @after: TradeDispute.close_resolved(trade_dispute)
          |> Repo.update()
        end
    end
  end

  def transition_under_review_to_escalated_trade_dispute(%TradeDispute{} = trade_dispute) do
    case TradeDispute.assert_transition(trade_dispute, "Escalated") do
      {:error, msg} -> {:error, :conflict, msg}
      :ok ->
          trade_dispute
          |> Ecto.Changeset.change(%{status: "Escalated"})
          # @after: TradeDispute.escalate(trade_dispute)
          |> Repo.update()
    end
  end

  def transition_escalated_to_resolved_trade_dispute(%TradeDispute{} = trade_dispute) do
    case TradeDispute.assert_transition(trade_dispute, "Resolved") do
      {:error, msg} -> {:error, :conflict, msg}
      :ok ->
        if is_nil(trade_dispute.resolution) do
          {:error, :unprocessable, "resolution is required for Escalated -> Resolved"}
        else
          trade_dispute
          |> Ecto.Changeset.change(%{status: "Resolved"})
          # @after: TradeDispute.close_resolved(trade_dispute)
          |> Repo.update()
        end
    end
  end

end
