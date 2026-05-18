from __future__ import annotations

from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict

class ProductBase(BaseModel):
    name: str
    product_type: str
    price: float
    stock: int
    active: bool
    discount_percent: int
    description: str | None = None
    image_url: str | None = None
    featured: bool
    card_id: int | None = None
    card_set_id: int | None = None


class ProductCreate(ProductBase):
    pass


class ProductUpdate(BaseModel):
    name: str | None = None
    product_type: str | None = None
    price: float | None = None
    stock: int | None = None
    active: bool | None = None
    discount_percent: int | None = None
    description: str | None = None
    image_url: str | None = None
    featured: bool | None = None
    card_id: int | None = None
    card_set_id: int | None = None


class ProductRead(ProductBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class OrderBase(BaseModel):
    status: str
    total: float
    discount_applied: float
    currency: str
    payment_method: str | None = None
    payment_reference: str | None = None
    shipping_address: str | None = None
    tracking_number: str | None = None
    created_at: datetime
    paid_at: datetime | None = None
    shipped_at: datetime | None = None
    player_id: int
    coupon_id: int | None = None


class OrderCreate(OrderBase):
    pass


class OrderUpdate(BaseModel):
    status: str | None = None
    total: float | None = None
    discount_applied: float | None = None
    currency: str | None = None
    payment_method: str | None = None
    payment_reference: str | None = None
    shipping_address: str | None = None
    tracking_number: str | None = None
    created_at: datetime | None = None
    paid_at: datetime | None = None
    shipped_at: datetime | None = None
    player_id: int | None = None
    coupon_id: int | None = None


class OrderRead(OrderBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class OrderItemBase(BaseModel):
    quantity: int
    price_at_purchase: float
    foil: bool
    order_id: int | None = None
    product_id: int


class OrderItemCreate(OrderItemBase):
    pass


class OrderItemUpdate(BaseModel):
    quantity: int | None = None
    price_at_purchase: float | None = None
    foil: bool | None = None
    order_id: int | None = None
    product_id: int | None = None


class OrderItemRead(OrderItemBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class CouponBase(BaseModel):
    code: str
    discount_type: str
    discount_value: float
    min_order_value: float
    max_uses: int | None = None
    uses_count: int
    valid_from: datetime
    valid_until: datetime
    is_active: bool


class CouponCreate(CouponBase):
    pass


class CouponUpdate(BaseModel):
    code: str | None = None
    discount_type: str | None = None
    discount_value: float | None = None
    min_order_value: float | None = None
    max_uses: int | None = None
    uses_count: int | None = None
    valid_from: datetime | None = None
    valid_until: datetime | None = None
    is_active: bool | None = None


class CouponRead(CouponBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class TradeListingBase(BaseModel):
    listing_type: str
    asking_price: float | None = None
    auction_start_price: float | None = None
    auction_current_bid: float | None = None
    auction_end_time: datetime | None = None
    foil: bool
    condition: str
    quantity: int
    status: str
    description: str | None = None
    created_at: datetime
    expires_at: datetime | None = None
    seller_id: int
    card_id: int


class TradeListingCreate(TradeListingBase):
    pass


class TradeListingUpdate(BaseModel):
    listing_type: str | None = None
    asking_price: float | None = None
    auction_start_price: float | None = None
    auction_current_bid: float | None = None
    auction_end_time: datetime | None = None
    foil: bool | None = None
    condition: str | None = None
    quantity: int | None = None
    status: str | None = None
    description: str | None = None
    created_at: datetime | None = None
    expires_at: datetime | None = None
    seller_id: int | None = None
    card_id: int | None = None


class TradeListingRead(TradeListingBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class TradeBidBase(BaseModel):
    amount: float
    placed_at: datetime
    is_winning: bool
    listing_id: int
    bidder_id: int


class TradeBidCreate(TradeBidBase):
    pass


class TradeBidUpdate(BaseModel):
    amount: float | None = None
    placed_at: datetime | None = None
    is_winning: bool | None = None
    listing_id: int | None = None
    bidder_id: int | None = None


class TradeBidRead(TradeBidBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class TradeTransactionBase(BaseModel):
    final_price: float
    platform_fee: float
    status: str
    completed_at: datetime | None = None
    listing_id: int
    buyer_id: int
    seller_id: int


class TradeTransactionCreate(TradeTransactionBase):
    pass


class TradeTransactionUpdate(BaseModel):
    final_price: float | None = None
    platform_fee: float | None = None
    status: str | None = None
    completed_at: datetime | None = None
    listing_id: int | None = None
    buyer_id: int | None = None
    seller_id: int | None = None


class TradeTransactionRead(TradeTransactionBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class CardPriceHistoryBase(BaseModel):
    price_date: date
    avg_price: float
    min_price: float
    max_price: float
    volume: int
    foil: bool
    card_id: int


class CardPriceHistoryCreate(CardPriceHistoryBase):
    pass


class CardPriceHistoryUpdate(BaseModel):
    price_date: date | None = None
    avg_price: float | None = None
    min_price: float | None = None
    max_price: float | None = None
    volume: int | None = None
    foil: bool | None = None
    card_id: int | None = None


class CardPriceHistoryRead(CardPriceHistoryBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class TradeDisputeBase(BaseModel):
    reason: str
    description: str
    status: str
    resolution: str | None = None
    opened_at: datetime
    resolved_at: datetime | None = None
    transaction_id: int
    opened_by_id: int
    resolved_by_id: int | None = None


class TradeDisputeCreate(TradeDisputeBase):
    pass


class TradeDisputeUpdate(BaseModel):
    reason: str | None = None
    description: str | None = None
    status: str | None = None
    resolution: str | None = None
    opened_at: datetime | None = None
    resolved_at: datetime | None = None
    transaction_id: int | None = None
    opened_by_id: int | None = None
    resolved_by_id: int | None = None


class TradeDisputeRead(TradeDisputeBase):
    id: int
    model_config = ConfigDict(from_attributes=True)
