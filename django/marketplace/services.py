"""
Domain services for the Marketplace BC bounded context.
Place business logic that doesn't belong to a single model here.
"""


class ProductService:
    """Domain service for Product aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new Product."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing Product."""
        raise NotImplementedError

    @staticmethod
    def activate(id):
        from .models import Product
        instance = Product.objects.get(pk=id)
        instance.activate()
        instance.save()

    @staticmethod
    def deactivate(id):
        from .models import Product
        instance = Product.objects.get(pk=id)
        instance.deactivate()
        instance.save()

    @staticmethod
    def apply_discount(id, percent):
        from .models import Product
        instance = Product.objects.get(pk=id)
        result = instance.apply_discount(percent)
        instance.save()
        return result

    @staticmethod
    def restock(id, quantity):
        from .models import Product
        instance = Product.objects.get(pk=id)
        instance.restock(quantity)
        instance.save()

    @staticmethod
    def effective_price(id):
        from .models import Product
        instance = Product.objects.get(pk=id)
        result = instance.effective_price()
        instance.save()
        return result

    @staticmethod
    def is_in_stock(id):
        from .models import Product
        instance = Product.objects.get(pk=id)
        result = instance.is_in_stock()
        instance.save()
        return result


class OrderService:
    """Domain service for Order aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new Order."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing Order."""
        raise NotImplementedError

    @staticmethod
    def cancel(id):
        from .models import Order
        instance = Order.objects.get(pk=id)
        instance.cancel()
        instance.save()

    @staticmethod
    def pay(id, payment_ref):
        from .models import Order
        instance = Order.objects.get(pk=id)
        result = instance.pay(payment_ref)
        instance.save()
        return result

    @staticmethod
    def calculate_total(id):
        from .models import Order
        instance = Order.objects.get(pk=id)
        result = instance.calculate_total()
        instance.save()
        return result

    @staticmethod
    def apply_discount(id, percent):
        from .models import Order
        instance = Order.objects.get(pk=id)
        result = instance.apply_discount(percent)
        instance.save()
        return result

    @staticmethod
    def refund(id):
        from .models import Order
        instance = Order.objects.get(pk=id)
        instance.refund()
        instance.save()

    # triggered by @on(status = Shipped)
    @staticmethod
    def set_status(pk, value):
        from .models import Order, OrderStatusChoices
        instance = Order.objects.get(pk=pk)
        instance.status = value
        if value == OrderStatusChoices.SHIPPED:
            instance.notify_shipped()
        instance.save()


class OrderItemService:
    """Domain service for OrderItem aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new OrderItem."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing OrderItem."""
        raise NotImplementedError

    @staticmethod
    def line_total(id):
        from .models import OrderItem
        instance = OrderItem.objects.get(pk=id)
        result = instance.line_total()
        instance.save()
        return result


class CouponService:
    """Domain service for Coupon aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new Coupon."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing Coupon."""
        raise NotImplementedError

    @staticmethod
    def is_valid(id):
        from .models import Coupon
        instance = Coupon.objects.get(pk=id)
        result = instance.is_valid()
        instance.save()
        return result

    @staticmethod
    def is_applicable_to_order(id):
        from .models import Coupon
        instance = Coupon.objects.get(pk=id)
        result = instance.is_applicable_to_order(order_total)
        instance.save()
        return result

    @staticmethod
    def redeem(id):
        from .models import Coupon
        instance = Coupon.objects.get(pk=id)
        instance.redeem()
        instance.save()

    @staticmethod
    def deactivate(id):
        from .models import Coupon
        instance = Coupon.objects.get(pk=id)
        instance.deactivate()
        instance.save()


class TradeListingService:
    """Domain service for TradeListing aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new TradeListing."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing TradeListing."""
        raise NotImplementedError

    @staticmethod
    def close(id):
        from .models import TradeListing
        instance = TradeListing.objects.get(pk=id)
        instance.close()
        instance.save()

    @staticmethod
    def extend(id, days):
        from .models import TradeListing
        instance = TradeListing.objects.get(pk=id)
        instance.extend(days)
        instance.save()

    @staticmethod
    def cancel(id):
        from .models import TradeListing
        instance = TradeListing.objects.get(pk=id)
        instance.cancel()
        instance.save()

    @staticmethod
    def is_expired(id):
        from .models import TradeListing
        instance = TradeListing.objects.get(pk=id)
        result = instance.is_expired()
        instance.save()
        return result

    @staticmethod
    def finalize_auction(id):
        from .models import TradeListing
        instance = TradeListing.objects.get(pk=id)
        instance.finalize_auction()
        instance.save()

    # triggered by @on(status = Sold)
    @staticmethod
    def set_status(pk, value):
        from .models import TradeListing, TradeListingStatusChoices
        instance = TradeListing.objects.get(pk=pk)
        instance.status = value
        if value == TradeListingStatusChoices.SOLD:
            instance.finalize_auction()
        instance.save()


class TradeBidService:
    """Domain service for TradeBid aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new TradeBid."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing TradeBid."""
        raise NotImplementedError

    @staticmethod
    def outbid_by(id):
        from .models import TradeBid
        instance = TradeBid.objects.get(pk=id)
        result = instance.outbid_by(new_amount)
        instance.save()
        return result

    @staticmethod
    def retract(id):
        from .models import TradeBid
        instance = TradeBid.objects.get(pk=id)
        instance.retract()
        instance.save()


class TradeTransactionService:
    """Domain service for TradeTransaction aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new TradeTransaction."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing TradeTransaction."""
        raise NotImplementedError

    @staticmethod
    def complete(id):
        from .models import TradeTransaction
        instance = TradeTransaction.objects.get(pk=id)
        instance.complete()
        instance.save()

    @staticmethod
    def refund(id):
        from .models import TradeTransaction
        instance = TradeTransaction.objects.get(pk=id)
        instance.refund()
        instance.save()

    @staticmethod
    def open_dispute(id, reason):
        from .models import TradeTransaction
        instance = TradeTransaction.objects.get(pk=id)
        instance.open_dispute(reason)
        instance.save()

    @staticmethod
    def seller_net(id):
        from .models import TradeTransaction
        instance = TradeTransaction.objects.get(pk=id)
        result = instance.seller_net()
        instance.save()
        return result


class CardPriceHistoryService:
    """Domain service for CardPriceHistory aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new CardPriceHistory."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing CardPriceHistory."""
        raise NotImplementedError

    @staticmethod
    def price_change_percent(id):
        from .models import CardPriceHistory
        instance = CardPriceHistory.objects.get(pk=id)
        result = instance.price_change_percent(previous_avg)
        instance.save()
        return result

    @staticmethod
    def is_price_spike(id):
        from .models import CardPriceHistory
        instance = CardPriceHistory.objects.get(pk=id)
        result = instance.is_price_spike(threshold_percent)
        instance.save()
        return result


class TradeDisputeService:
    """Domain service for TradeDispute aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new TradeDispute."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing TradeDispute."""
        raise NotImplementedError

    @staticmethod
    def escalate(id):
        from .models import TradeDispute
        instance = TradeDispute.objects.get(pk=id)
        instance.escalate()
        instance.save()

    @staticmethod
    def resolve(id, resolution_text):
        from .models import TradeDispute
        instance = TradeDispute.objects.get(pk=id)
        instance.resolve(resolution_text)
        instance.save()

    @staticmethod
    def review(id):
        from .models import TradeDispute
        instance = TradeDispute.objects.get(pk=id)
        instance.review()
        instance.save()
