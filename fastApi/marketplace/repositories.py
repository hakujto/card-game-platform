"""
Repository layer for the Marketplace BC bounded context.
Abstracts data access from domain logic.
"""

from sqlalchemy.orm import Session

from .models import Product, Order, OrderItem, Coupon, TradeListing, TradeBid, TradeTransaction, CardPriceHistory, TradeDispute


class ProductRepository:
    """Repository for Product."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> Product | None:
        return db.query(Product).filter(Product.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[Product]:
        return db.query(Product).all()


class OrderRepository:
    """Repository for Order."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> Order | None:
        return db.query(Order).filter(Order.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[Order]:
        return db.query(Order).all()


class OrderItemRepository:
    """Repository for OrderItem."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> OrderItem | None:
        return db.query(OrderItem).filter(OrderItem.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[OrderItem]:
        return db.query(OrderItem).all()


class CouponRepository:
    """Repository for Coupon."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> Coupon | None:
        return db.query(Coupon).filter(Coupon.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[Coupon]:
        return db.query(Coupon).all()


class TradeListingRepository:
    """Repository for TradeListing."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> TradeListing | None:
        return db.query(TradeListing).filter(TradeListing.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[TradeListing]:
        return db.query(TradeListing).all()


class TradeBidRepository:
    """Repository for TradeBid."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> TradeBid | None:
        return db.query(TradeBid).filter(TradeBid.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[TradeBid]:
        return db.query(TradeBid).all()


class TradeTransactionRepository:
    """Repository for TradeTransaction."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> TradeTransaction | None:
        return db.query(TradeTransaction).filter(TradeTransaction.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[TradeTransaction]:
        return db.query(TradeTransaction).all()


class CardPriceHistoryRepository:
    """Repository for CardPriceHistory."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> CardPriceHistory | None:
        return db.query(CardPriceHistory).filter(CardPriceHistory.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[CardPriceHistory]:
        return db.query(CardPriceHistory).all()


class TradeDisputeRepository:
    """Repository for TradeDispute."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> TradeDispute | None:
        return db.query(TradeDispute).filter(TradeDispute.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[TradeDispute]:
        return db.query(TradeDispute).all()
