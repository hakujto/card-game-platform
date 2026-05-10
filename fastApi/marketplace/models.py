from __future__ import annotations

from sqlalchemy import (
    Boolean, Column, Date, DateTime, Float, ForeignKey, Integer,
    JSON, Numeric, SmallInteger, String, Table, Text,
)
from sqlalchemy.orm import relationship

from app.db import Base

from typing import Literal

ProductProductTypeType = Literal["SingleCard", "BoosterPack", "Bundle", "PreconstructedDeck", "Accessory"]

class Product(Base):
    __tablename__ = "product"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200))
    product_type = Column(String(20), default="SingleCard")
    price = Column(Numeric)
    stock = Column(Integer, default="0")
    active = Column(Boolean, default="true")
    discount_percent = Column(Integer, default="0")
    description = Column(Text, nullable=True)
    image_url = Column(String(200), nullable=True)
    featured = Column(Boolean, default="false")
    card_id = Column(Integer, ForeignKey("card.id"), nullable=True)
    card = relationship("Card", foreign_keys=[card_id])
    card_set_id = Column(Integer, ForeignKey("card_set.id"), nullable=True)
    card_set = relationship("CardSet", foreign_keys=[card_set_id])

    def __repr__(self) -> str:
        return f"<Product id={{self.id}}>"


from typing import Literal

OrderStatusType = Literal["Pending", "Paid", "Processing", "Shipped", "Completed", "Cancelled", "Refunded"]
OrderPaymentMethodType = Literal["Card", "PayPal", "Crypto", "PlatformCredits"]

class Order(Base):
    __tablename__ = "order"

    id = Column(Integer, primary_key=True, index=True)
    status = Column(String(20), default="Pending")
    total = Column(Numeric, default="0")
    discount_applied = Column(Numeric, default="0")
    currency = Column(String(3), default="USD")
    payment_method = Column(String(20), nullable=True)
    payment_reference = Column(String(200), nullable=True)
    shipping_address = Column(Text, nullable=True)
    tracking_number = Column(String(100), nullable=True)
    created_at = Column(DateTime)
    paid_at = Column(DateTime, nullable=True)
    shipped_at = Column(DateTime, nullable=True)
    player_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    player = relationship("Player", foreign_keys=[player_id])
    items_id = Column(Integer, ForeignKey("order_item.id"), nullable=False)
    items = relationship("OrderItem", foreign_keys=[items_id])
    coupon_id = Column(Integer, ForeignKey("coupon.id"), nullable=True)
    coupon = relationship("Coupon", foreign_keys=[coupon_id])

    def __repr__(self) -> str:
        return f"<Order id={{self.id}}>"


class OrderItem(Base):
    __tablename__ = "order_item"

    id = Column(Integer, primary_key=True, index=True)
    quantity = Column(Integer)
    price_at_purchase = Column(Numeric)
    foil = Column(Boolean, default="false")
    order_id = Column(Integer, ForeignKey("order.id"), nullable=True)
    order = relationship("Order", foreign_keys=[order_id])
    product_id = Column(Integer, ForeignKey("product.id"), nullable=False)
    product = relationship("Product", foreign_keys=[product_id])

    def __repr__(self) -> str:
        return f"<OrderItem id={{self.id}}>"


from typing import Literal

CouponDiscountTypeType = Literal["Percent", "Fixed"]

class Coupon(Base):
    __tablename__ = "coupon"

    id = Column(Integer, primary_key=True, index=True)
    code = Column(String(50))
    discount_type = Column(String(20), default="Percent")
    discount_value = Column(Numeric)
    min_order_value = Column(Numeric, default="0")
    max_uses = Column(Integer, nullable=True)
    uses_count = Column(Integer, default="0")
    valid_from = Column(DateTime)
    valid_until = Column(DateTime)
    is_active = Column(Boolean, default="true")

    def __repr__(self) -> str:
        return f"<Coupon id={{self.id}}>"


from typing import Literal

TradelistingListingTypeType = Literal["FixedPrice", "Auction", "TradeOffer"]
TradelistingConditionType = Literal["Mint", "NearMint", "Excellent", "Good", "Played"]
TradelistingStatusType = Literal["Active", "Sold", "Expired", "Cancelled", "Pending"]

class Tradelisting(Base):
    __tablename__ = "tradelisting"

    id = Column(Integer, primary_key=True, index=True)
    listing_type = Column(String(20), default="FixedPrice")
    asking_price = Column(Numeric, nullable=True)
    auction_start_price = Column(Numeric, nullable=True)
    auction_current_bid = Column(Numeric, nullable=True)
    auction_end_time = Column(DateTime, nullable=True)
    foil = Column(Boolean, default="false")
    condition = Column(String(20), default="Mint")
    quantity = Column(Integer, default="1")
    status = Column(String(20), default="Active")
    description = Column(Text, nullable=True)
    created_at = Column(DateTime)
    expires_at = Column(DateTime, nullable=True)
    seller_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    seller = relationship("Player", foreign_keys=[seller_id])
    card_id = Column(Integer, ForeignKey("card.id"), nullable=False)
    card = relationship("Card", foreign_keys=[card_id])
    bids_id = Column(Integer, ForeignKey("trade_bid.id"), nullable=True)
    bids = relationship("TradeBid", foreign_keys=[bids_id])

    def __repr__(self) -> str:
        return f"<Tradelisting id={{self.id}}>"


class TradeBid(Base):
    __tablename__ = "trade_bid"

    id = Column(Integer, primary_key=True, index=True)
    amount = Column(Numeric)
    placed_at = Column(DateTime)
    is_winning = Column(Boolean, default="false")
    listing_id = Column(Integer, ForeignKey("tradelisting.id"), nullable=False)
    listing = relationship("Tradelisting", foreign_keys=[listing_id])
    bidder_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    bidder = relationship("Player", foreign_keys=[bidder_id])

    def __repr__(self) -> str:
        return f"<TradeBid id={{self.id}}>"


from typing import Literal

TradeTransactionStatusType = Literal["Pending", "Completed", "Disputed", "Refunded"]

class TradeTransaction(Base):
    __tablename__ = "trade_transaction"

    id = Column(Integer, primary_key=True, index=True)
    final_price = Column(Numeric)
    platform_fee = Column(Numeric)
    status = Column(String(20), default="Pending")
    completed_at = Column(DateTime, nullable=True)
    listing_id = Column(Integer, ForeignKey("tradelisting.id"), nullable=False)
    listing = relationship("Tradelisting", foreign_keys=[listing_id])
    buyer_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    buyer = relationship("Player", foreign_keys=[buyer_id])
    seller_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    seller = relationship("Player", foreign_keys=[seller_id])

    def __repr__(self) -> str:
        return f"<TradeTransaction id={{self.id}}>"


class CardPriceHistory(Base):
    __tablename__ = "card_price_history"

    id = Column(Integer, primary_key=True, index=True)
    price_date = Column(Date)
    avg_price = Column(Numeric)
    min_price = Column(Numeric)
    max_price = Column(Numeric)
    volume = Column(Integer)
    foil = Column(Boolean, default="false")
    card_id = Column(Integer, ForeignKey("card.id"), nullable=False)
    card = relationship("Card", foreign_keys=[card_id])

    def __repr__(self) -> str:
        return f"<CardPriceHistory id={{self.id}}>"


from typing import Literal

TradeDisputeReasonType = Literal["ItemNotReceived", "ItemNotAsDescribed", "FraudSuspected", "Other"]
TradeDisputeStatusType = Literal["Open", "UnderReview", "Resolved", "Escalated"]

class TradeDispute(Base):
    __tablename__ = "trade_dispute"

    id = Column(Integer, primary_key=True, index=True)
    reason = Column(String(20))
    description = Column(Text)
    status = Column(String(20), default="Open")
    resolution = Column(Text, nullable=True)
    opened_at = Column(DateTime)
    resolved_at = Column(DateTime, nullable=True)
    transaction_id = Column(Integer, ForeignKey("trade_transaction.id"), nullable=False)
    transaction = relationship("TradeTransaction", foreign_keys=[transaction_id])
    opened_by_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    opened_by = relationship("Player", foreign_keys=[opened_by_id])
    resolved_by_id = Column(Integer, ForeignKey("player.id"), nullable=True)
    resolved_by = relationship("Player", foreign_keys=[resolved_by_id])

    def __repr__(self) -> str:
        return f"<TradeDispute id={{self.id}}>"
