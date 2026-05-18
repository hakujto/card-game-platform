"""
Domain services for the Marketplace BC bounded context.
Place business logic that does not belong to a single model here.
"""

from sqlalchemy.orm import Session

from .models import Product, Order, OrderItem, Coupon, TradeListing, TradeBid, TradeTransaction, CardPriceHistory, TradeDispute


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
    def effective_price(db: Session, pk: int) -> float:
        obj = db.query(Product).filter(Product.id == pk).first()
        if obj is None:
            raise ValueError("Product not found: " + str(pk))
        result = obj.effective_price()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def is_in_stock(db: Session, pk: int) -> bool:
        obj = db.query(Product).filter(Product.id == pk).first()
        if obj is None:
            raise ValueError("Product not found: " + str(pk))
        result = obj.is_in_stock()
        db.add(obj)
        db.commit()
        return result

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
    def line_total(db: Session, pk: int) -> float:
        obj = db.query(OrderItem).filter(OrderItem.id == pk).first()
        if obj is None:
            raise ValueError("OrderItem not found: " + str(pk))
        result = obj.line_total()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class CouponService:
    """Domain service for Coupon aggregate."""

    @staticmethod
    def is_valid(db: Session, pk: int) -> bool:
        obj = db.query(Coupon).filter(Coupon.id == pk).first()
        if obj is None:
            raise ValueError("Coupon not found: " + str(pk))
        result = obj.is_valid()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def is_applicable_to_order(db: Session, pk: int, order_total: float) -> bool:
        obj = db.query(Coupon).filter(Coupon.id == pk).first()
        if obj is None:
            raise ValueError("Coupon not found: " + str(pk))
        result = obj.is_applicable_to_order(order_total)
        db.add(obj)
        db.commit()
        return result

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


class TradeListingService:
    """Domain service for TradeListing aggregate."""

    @staticmethod
    def close(db: Session, pk: int):
        obj = db.query(TradeListing).filter(TradeListing.id == pk).first()
        if obj is None:
            raise ValueError("TradeListing not found: " + str(pk))
        obj.close()
        db.add(obj)
        db.commit()

    @staticmethod
    def extend(db: Session, pk: int, days: int):
        obj = db.query(TradeListing).filter(TradeListing.id == pk).first()
        if obj is None:
            raise ValueError("TradeListing not found: " + str(pk))
        obj.extend(days)
        db.add(obj)
        db.commit()

    @staticmethod
    def cancel(db: Session, pk: int):
        obj = db.query(TradeListing).filter(TradeListing.id == pk).first()
        if obj is None:
            raise ValueError("TradeListing not found: " + str(pk))
        obj.cancel()
        db.add(obj)
        db.commit()

    @staticmethod
    def is_expired(db: Session, pk: int) -> bool:
        obj = db.query(TradeListing).filter(TradeListing.id == pk).first()
        if obj is None:
            raise ValueError("TradeListing not found: " + str(pk))
        result = obj.is_expired()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def finalize_auction(db: Session, pk: int):
        obj = db.query(TradeListing).filter(TradeListing.id == pk).first()
        if obj is None:
            raise ValueError("TradeListing not found: " + str(pk))
        obj.finalize_auction()
        db.add(obj)
        db.commit()

    @staticmethod
    def set_status(db: Session, pk: int, value: TradeListingStatusType) -> None:
        obj = db.query(TradeListing).filter(TradeListing.id == pk).first()
        if obj is None:
            raise ValueError("TradeListing not found: " + str(pk))
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
    def outbid_by(db: Session, pk: int, new_amount: float) -> bool:
        obj = db.query(TradeBid).filter(TradeBid.id == pk).first()
        if obj is None:
            raise ValueError("TradeBid not found: " + str(pk))
        result = obj.outbid_by(new_amount)
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def retract(db: Session, pk: int):
        obj = db.query(TradeBid).filter(TradeBid.id == pk).first()
        if obj is None:
            raise ValueError("TradeBid not found: " + str(pk))
        obj.retract()
        db.add(obj)
        db.commit()

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
    def seller_net(db: Session, pk: int) -> float:
        obj = db.query(TradeTransaction).filter(TradeTransaction.id == pk).first()
        if obj is None:
            raise ValueError("TradeTransaction not found: " + str(pk))
        result = obj.seller_net()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class CardPriceHistoryService:
    """Domain service for CardPriceHistory aggregate."""

    @staticmethod
    def price_change_percent(db: Session, pk: int, previous_avg: float) -> float:
        obj = db.query(CardPriceHistory).filter(CardPriceHistory.id == pk).first()
        if obj is None:
            raise ValueError("CardPriceHistory not found: " + str(pk))
        result = obj.price_change_percent(previous_avg)
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def is_price_spike(db: Session, pk: int, threshold_percent: int) -> bool:
        obj = db.query(CardPriceHistory).filter(CardPriceHistory.id == pk).first()
        if obj is None:
            raise ValueError("CardPriceHistory not found: " + str(pk))
        result = obj.is_price_spike(threshold_percent)
        db.add(obj)
        db.commit()
        return result

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
