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

    def activate(self):
        raise NotImplementedError("activate not implemented")

    def deactivate(self):
        raise NotImplementedError("deactivate not implemented")

    def apply_discount(self, percent: int) -> float:
        raise NotImplementedError("apply_discount not implemented")

    def restock(self, quantity: int):
        raise NotImplementedError("restock not implemented")

    def effective_price(self) -> float:
        raise NotImplementedError("effective_price not implemented")

    def is_in_stock(self) -> bool:
        raise NotImplementedError("is_in_stock not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.price is None or self.price > 0)):
            errors.append("Product price must be greater than zero")
        if not ((self.stock is None or self.stock >= 0)):
            errors.append("Product stock must not be negative")
        if not ((self.discount_percent is None or (self.discount_percent >= 0 and self.discount_percent <= 100))):
            errors.append("Product discount percent must be between 0 and 100")
        return errors
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
    coupon_id = Column(Integer, ForeignKey("coupon.id"), nullable=True)
    coupon = relationship("Coupon", foreign_keys=[coupon_id])

    def cancel(self):
        raise NotImplementedError("cancel not implemented")

    def pay(self, payment_ref: str) -> bool:
        raise NotImplementedError("pay not implemented")

    def calculate_total(self) -> float:
        raise NotImplementedError("calculate_total not implemented")

    def apply_discount(self, percent: int) -> float:
        raise NotImplementedError("apply_discount not implemented")

    def refund(self):
        raise NotImplementedError("refund not implemented")

    def notify_shipped(self):
        raise NotImplementedError("notify_shipped not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.total is None or self.total >= 0)):
            errors.append("Order total must not be negative")
        if not ((self.discount_applied is None or (self.total is not None and self.discount_applied <= self.total))):
            errors.append("Discount applied cannot exceed order total")
        return errors

    def validate_implies(self) -> list[str]:
        errors = []
        if (self.status == "Paid") and not (self.paid_at is not None):
            errors.append("Paid order must have paid_at set")
        if (self.status == "Shipped") and not (self.tracking_number is not None):
            errors.append("Shipped order must have a tracking number")
        if (self.shipped_at is not None) and not (self.status == "Shipped"):
            errors.append("shipped_at_requires_shipped_status")
        return errors
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

    def line_total(self) -> float:
        raise NotImplementedError("line_total not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.quantity is None or self.quantity > 0)):
            errors.append("Order item quantity must be greater than zero")
        if not ((self.price_at_purchase is None or self.price_at_purchase >= 0)):
            errors.append("Price at purchase must not be negative")
        return errors
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

    def is_valid(self) -> bool:
        raise NotImplementedError("is_valid not implemented")

    def is_applicable_to_order(self, order_total: float) -> bool:
        raise NotImplementedError("is_applicable_to_order not implemented")

    def redeem(self):
        raise NotImplementedError("redeem not implemented")

    def deactivate(self):
        raise NotImplementedError("deactivate not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.valid_until is None or (self.valid_from is not None and self.valid_until > self.valid_from))):
            errors.append("Coupon expiry must be after its start date")
        if not ((self.discount_value is None or self.discount_value > 0)):
            errors.append("Discount value must be greater than zero")
        return errors

    def validate_implies(self) -> list[str]:
        errors = []
        if (self.discount_type == "Percent") and not ((self.discount_value is None or (self.discount_value >= 1 and self.discount_value <= 100))):
            errors.append("Percent discount must be between 1 and 100")
        if (self.max_uses is not None) and not ((self.uses_count is None or (self.max_uses is not None and self.uses_count <= self.max_uses))):
            errors.append("Coupon uses count cannot exceed max_uses")
        return errors
    def __repr__(self) -> str:
        return f"<Coupon id={{self.id}}>"


from typing import Literal

TradeListingListingTypeType = Literal["FixedPrice", "Auction", "TradeOffer"]
TradeListingConditionType = Literal["Mint", "NearMint", "Excellent", "Good", "Played"]
TradeListingStatusType = Literal["Active", "Sold", "Expired", "Cancelled", "Pending"]

class TradeListing(Base):
    __tablename__ = "trade_listing"

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

    def close(self):
        raise NotImplementedError("close not implemented")

    def extend(self, days: int):
        raise NotImplementedError("extend not implemented")

    def cancel(self):
        raise NotImplementedError("cancel not implemented")

    def is_expired(self) -> bool:
        raise NotImplementedError("is_expired not implemented")

    def finalize_auction(self):
        raise NotImplementedError("finalize_auction not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.quantity is None or (self.quantity >= 1 and self.quantity <= 9999))):
            errors.append("Listing quantity must be between 1 and 9999")
        return errors

    def validate_implies(self) -> list[str]:
        errors = []
        if (self.listing_type == "FixedPrice") and not (self.asking_price is not None):
            errors.append("Fixed price listing must have an asking price")
        if (self.listing_type == "Auction") and not ((self.auction_start_price is not None and self.auction_end_time is not None)):
            errors.append("Auction listing must have a start price and end time")
        return errors
    def __repr__(self) -> str:
        return f"<TradeListing id={{self.id}}>"


class TradeBid(Base):
    __tablename__ = "trade_bid"

    id = Column(Integer, primary_key=True, index=True)
    amount = Column(Numeric)
    placed_at = Column(DateTime)
    is_winning = Column(Boolean, default="false")
    listing_id = Column(Integer, ForeignKey("trade_listing.id"), nullable=False)
    listing = relationship("TradeListing", foreign_keys=[listing_id])
    bidder_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    bidder = relationship("Player", foreign_keys=[bidder_id])

    def outbid_by(self, new_amount: float) -> bool:
        raise NotImplementedError("outbid_by not implemented")

    def retract(self):
        raise NotImplementedError("retract not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.amount is None or self.amount > 0)):
            errors.append("Bid amount must be greater than zero")
        return errors
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
    listing_id = Column(Integer, ForeignKey("trade_listing.id"), nullable=False)
    listing = relationship("TradeListing", foreign_keys=[listing_id])
    buyer_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    buyer = relationship("Player", foreign_keys=[buyer_id])
    seller_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    seller = relationship("Player", foreign_keys=[seller_id])

    def complete(self):
        raise NotImplementedError("complete not implemented")

    def refund(self):
        raise NotImplementedError("refund not implemented")

    def open_dispute(self, reason: str):
        raise NotImplementedError("open_dispute not implemented")

    def seller_net(self) -> float:
        raise NotImplementedError("seller_net not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.platform_fee is None or (self.final_price is not None and self.platform_fee <= self.final_price))):
            errors.append("Platform fee cannot exceed the final price")
        if not ((self.platform_fee is None or self.platform_fee >= 0)):
            errors.append("Platform fee must not be negative")
        if not ((self.final_price is None or self.final_price > 0)):
            errors.append("Transaction final price must be greater than zero")
        return errors

    def validate_implies(self) -> list[str]:
        errors = []
        if (self.status == "Completed") and not (self.completed_at is not None):
            errors.append("Completed transaction must have a completed_at timestamp")
        return errors
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

    def price_change_percent(self, previous_avg: float) -> float:
        raise NotImplementedError("price_change_percent not implemented")

    def is_price_spike(self, threshold_percent: int) -> bool:
        raise NotImplementedError("is_price_spike not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not (((self.min_price is None or (self.avg_price is not None and self.min_price <= self.avg_price)) and (self.avg_price is None or (self.max_price is not None and self.avg_price <= self.max_price)))):
            errors.append("min_price <= avg_price <= max_price must hold")
        if not ((self.volume is None or self.volume >= 0)):
            errors.append("Price history volume must not be negative")
        if not ((self.min_price is None or self.min_price >= 0)):
            errors.append("Prices must not be negative")
        return errors
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

    def escalate(self):
        raise NotImplementedError("escalate not implemented")

    def resolve(self, resolution_text: str):
        raise NotImplementedError("resolve not implemented")

    def review(self):
        raise NotImplementedError("review not implemented")


    def validate_implies(self) -> list[str]:
        errors = []
        if (self.resolved_at is not None) and not (self.status == "Resolved"):
            errors.append("resolved_at_requires_terminal_status")
        return errors
    def __repr__(self) -> str:
        return f"<TradeDispute id={{self.id}}>"
