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


class TradelistingService:
    """Domain service for Tradelisting aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new Tradelisting."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing Tradelisting."""
        raise NotImplementedError


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
