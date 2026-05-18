"""
Repository layer for the Marketplace BC bounded context.
Abstracts data access from domain logic.
"""


class ProductRepository:
    """Repository for Product."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import Product
        return Product.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import Product
        return Product.objects.all()


class OrderRepository:
    """Repository for Order."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import Order
        return Order.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import Order
        return Order.objects.all()


class OrderItemRepository:
    """Repository for OrderItem."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import OrderItem
        return OrderItem.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import OrderItem
        return OrderItem.objects.all()


class CouponRepository:
    """Repository for Coupon."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import Coupon
        return Coupon.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import Coupon
        return Coupon.objects.all()


class TradeListingRepository:
    """Repository for TradeListing."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import TradeListing
        return TradeListing.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import TradeListing
        return TradeListing.objects.all()


class TradeBidRepository:
    """Repository for TradeBid."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import TradeBid
        return TradeBid.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import TradeBid
        return TradeBid.objects.all()


class TradeTransactionRepository:
    """Repository for TradeTransaction."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import TradeTransaction
        return TradeTransaction.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import TradeTransaction
        return TradeTransaction.objects.all()


class CardPriceHistoryRepository:
    """Repository for CardPriceHistory."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import CardPriceHistory
        return CardPriceHistory.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import CardPriceHistory
        return CardPriceHistory.objects.all()


class TradeDisputeRepository:
    """Repository for TradeDispute."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import TradeDispute
        return TradeDispute.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import TradeDispute
        return TradeDispute.objects.all()
