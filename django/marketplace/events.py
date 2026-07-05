"""
Domain events for the Marketplace BC bounded context.
Emitted by aggregate behaviors via @emits — see services.py for dispatch stubs.
"""
from dataclasses import dataclass
from datetime import date, datetime
from decimal import Decimal
from typing import Optional
from uuid import UUID


@dataclass
class OrderPaid:
    order_id: int
    player_id: int
    total: Decimal
    payment_method: str
    paid_at: datetime


@dataclass
class OrderShipped:
    order_id: int
    tracking_number: str
    shipped_at: datetime


@dataclass
class OrderRefunded:
    order_id: int
    refunded_at: datetime


@dataclass
class TransactionCompleted:
    transaction_id: int
    buyer_id: int
    seller_id: int
    final_price: Decimal
    completed_at: datetime
