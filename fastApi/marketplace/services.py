"""
Domain services for the Marketplace BC bounded context.
Place business logic that does not belong to a single model here.
"""

from sqlalchemy.orm import Session

from .models import Product, Order, OrderItem, Coupon, Tradelisting, TradeBid, TradeTransaction, CardPriceHistory, TradeDispute


class ProductService:
    """Domain service for Product aggregate."""

    @staticmethod
    def activate(db: Session, pk: int):
        obj = db.query(Product).filter(Product.id == pk).first()
        if obj is None:
            raise ValueError("Product not found: " + str(pk))
        obj.activate()
        db.add(obj)
        db.commit()

    @staticmethod
    def deactivate(db: Session, pk: int):
        obj = db.query(Product).filter(Product.id == pk).first()
        if obj is None:
            raise ValueError("Product not found: " + str(pk))
        obj.deactivate()
        db.add(obj)
        db.commit()

    @staticmethod
    def apply_discount(db: Session, pk: int, percent: int) -> float:
        obj = db.query(Product).filter(Product.id == pk).first()
        if obj is None:
            raise ValueError("Product not found: " + str(pk))
        result = obj.apply_discount(percent)
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def restock(db: Session, pk: int, quantity: int):
        obj = db.query(Product).filter(Product.id == pk).first()
        if obj is None:
            raise ValueError("Product not found: " + str(pk))
        obj.restock(quantity)
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class OrderService:
    """Domain service for Order aggregate."""

    @staticmethod
    def cancel(db: Session, pk: int):
        obj = db.query(Order).filter(Order.id == pk).first()
        if obj is None:
            raise ValueError("Order not found: " + str(pk))
        obj.cancel()
        db.add(obj)
        db.commit()

    @staticmethod
    def pay(db: Session, pk: int, payment_ref: str) -> bool:
        obj = db.query(Order).filter(Order.id == pk).first()
        if obj is None:
            raise ValueError("Order not found: " + str(pk))
        result = obj.pay(payment_ref)
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def calculate_total(db: Session, pk: int) -> float:
        obj = db.query(Order).filter(Order.id == pk).first()
        if obj is None:
            raise ValueError("Order not found: " + str(pk))
        result = obj.calculate_total()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def apply_discount(db: Session, pk: int, percent: int) -> float:
        obj = db.query(Order).filter(Order.id == pk).first()
        if obj is None:
            raise ValueError("Order not found: " + str(pk))
        result = obj.apply_discount(percent)
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def refund(db: Session, pk: int):
        obj = db.query(Order).filter(Order.id == pk).first()
        if obj is None:
            raise ValueError("Order not found: " + str(pk))
        obj.refund()
        db.add(obj)
        db.commit()

    @staticmethod
    def set_status(db: Session, pk: int, value: OrderStatusType) -> None:
        obj = db.query(Order).filter(Order.id == pk).first()
        if obj is None:
            raise ValueError("Order not found: " + str(pk))
        obj.status = value
        if value == "SHIPPED":
            obj.notify_shipped()  # @on(status = Shipped)
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class OrderItemService:
    """Domain service for OrderItem aggregate."""

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class CouponService:
    """Domain service for Coupon aggregate."""

    @staticmethod
    def redeem(db: Session, pk: int):
        obj = db.query(Coupon).filter(Coupon.id == pk).first()
        if obj is None:
            raise ValueError("Coupon not found: " + str(pk))
        obj.redeem()
        db.add(obj)
        db.commit()

    @staticmethod
    def deactivate(db: Session, pk: int):
        obj = db.query(Coupon).filter(Coupon.id == pk).first()
        if obj is None:
            raise ValueError("Coupon not found: " + str(pk))
        obj.deactivate()
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class TradelistingService:
    """Domain service for Tradelisting aggregate."""

    @staticmethod
    def close(db: Session, pk: int):
        obj = db.query(Tradelisting).filter(Tradelisting.id == pk).first()
        if obj is None:
            raise ValueError("Tradelisting not found: " + str(pk))
        obj.close()
        db.add(obj)
        db.commit()

    @staticmethod
    def extend(db: Session, pk: int, days: int):
        obj = db.query(Tradelisting).filter(Tradelisting.id == pk).first()
        if obj is None:
            raise ValueError("Tradelisting not found: " + str(pk))
        obj.extend(days)
        db.add(obj)
        db.commit()

    @staticmethod
    def cancel(db: Session, pk: int):
        obj = db.query(Tradelisting).filter(Tradelisting.id == pk).first()
        if obj is None:
            raise ValueError("Tradelisting not found: " + str(pk))
        obj.cancel()
        db.add(obj)
        db.commit()

    @staticmethod
    def set_status(db: Session, pk: int, value: TradelistingStatusType) -> None:
        obj = db.query(Tradelisting).filter(Tradelisting.id == pk).first()
        if obj is None:
            raise ValueError("Tradelisting not found: " + str(pk))
        obj.status = value
        if value == "SOLD":
            obj.finalize_auction()  # @on(status = Sold)
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class TradeBidService:
    """Domain service for TradeBid aggregate."""

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class TradeTransactionService:
    """Domain service for TradeTransaction aggregate."""

    @staticmethod
    def complete(db: Session, pk: int):
        obj = db.query(TradeTransaction).filter(TradeTransaction.id == pk).first()
        if obj is None:
            raise ValueError("TradeTransaction not found: " + str(pk))
        obj.complete()
        db.add(obj)
        db.commit()

    @staticmethod
    def refund(db: Session, pk: int):
        obj = db.query(TradeTransaction).filter(TradeTransaction.id == pk).first()
        if obj is None:
            raise ValueError("TradeTransaction not found: " + str(pk))
        obj.refund()
        db.add(obj)
        db.commit()

    @staticmethod
    def open_dispute(db: Session, pk: int, reason: str):
        obj = db.query(TradeTransaction).filter(TradeTransaction.id == pk).first()
        if obj is None:
            raise ValueError("TradeTransaction not found: " + str(pk))
        obj.open_dispute(reason)
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class CardPriceHistoryService:
    """Domain service for CardPriceHistory aggregate."""

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class TradeDisputeService:
    """Domain service for TradeDispute aggregate."""

    @staticmethod
    def escalate(db: Session, pk: int):
        obj = db.query(TradeDispute).filter(TradeDispute.id == pk).first()
        if obj is None:
            raise ValueError("TradeDispute not found: " + str(pk))
        obj.escalate()
        db.add(obj)
        db.commit()

    @staticmethod
    def resolve(db: Session, pk: int, resolution_text: str):
        obj = db.query(TradeDispute).filter(TradeDispute.id == pk).first()
        if obj is None:
            raise ValueError("TradeDispute not found: " + str(pk))
        obj.resolve(resolution_text)
        db.add(obj)
        db.commit()

    @staticmethod
    def review(db: Session, pk: int):
        obj = db.query(TradeDispute).filter(TradeDispute.id == pk).first()
        if obj is None:
            raise ValueError("TradeDispute not found: " + str(pk))
        obj.review()
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError
