from rest_framework import serializers
from .models import Product, Order, OrderItem, Coupon, TradeListing, TradeBid, TradeTransaction, CardPriceHistory, TradeDispute


class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = [
            "id",
            "name",
            "product_type",
            "price",
            "stock",
            "active",
            "discount_percent",
            "description",
            "image_url",
            "featured",
            "card",
            "card_set",
        ]
        read_only_fields = ["id"]


class OrderSerializer(serializers.ModelSerializer):
    createdAt = serializers.DateTimeField(source="created_at")
    paidAt = serializers.DateTimeField(source="paid_at", required=False, allow_null=True)
    shippedAt = serializers.DateTimeField(source="shipped_at", required=False, allow_null=True)
    class Meta:
        model = Order
        fields = [
            "id",
            "status",
            "total",
            "discount_applied",
            "currency",
            "payment_method",
            "payment_reference",
            "shipping_address",
            "tracking_number",
            "createdAt",
            "paidAt",
            "shippedAt",
            "player",
            "coupon",
        ]
        read_only_fields = ["id"]


class OrderItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderItem
        fields = [
            "id",
            "quantity",
            "price_at_purchase",
            "foil",
            "order",
            "product",
        ]
        read_only_fields = ["id"]


class CouponSerializer(serializers.ModelSerializer):
    class Meta:
        model = Coupon
        fields = [
            "id",
            "code",
            "discount_type",
            "discount_value",
            "min_order_value",
            "max_uses",
            "uses_count",
            "valid_from",
            "valid_until",
            "is_active",
        ]
        read_only_fields = ["id"]


class TradeListingSerializer(serializers.ModelSerializer):
    createdAt = serializers.DateTimeField(source="created_at")
    expiresAt = serializers.DateTimeField(source="expires_at", required=False, allow_null=True)
    auctionEndTime = serializers.DateTimeField(source="auction_end_time", required=False, allow_null=True)
    class Meta:
        model = TradeListing
        fields = [
            "id",
            "status",
            "listing_type",
            "asking_price",
            "auction_start_price",
            "auction_current_bid",
            "auctionEndTime",
            "foil",
            "condition",
            "quantity",
            "description",
            "createdAt",
            "expiresAt",
            "seller",
            "card",
        ]
        read_only_fields = ["id"]


class TradeBidSerializer(serializers.ModelSerializer):
    placedAt = serializers.DateTimeField(source="placed_at")
    class Meta:
        model = TradeBid
        fields = [
            "id",
            "amount",
            "placedAt",
            "is_winning",
            "listing",
            "bidder",
        ]
        read_only_fields = ["id"]


class TradeTransactionSerializer(serializers.ModelSerializer):
    completedAt = serializers.DateTimeField(source="completed_at", required=False, allow_null=True)
    class Meta:
        model = TradeTransaction
        fields = [
            "id",
            "final_price",
            "platform_fee",
            "status",
            "completedAt",
            "listing",
            "buyer",
            "seller",
        ]
        read_only_fields = ["id"]


class CardPriceHistorySerializer(serializers.ModelSerializer):
    class Meta:
        model = CardPriceHistory
        fields = [
            "id",
            "price_date",
            "avg_price",
            "min_price",
            "max_price",
            "volume",
            "foil",
            "card",
        ]
        read_only_fields = ["id"]


class TradeDisputeSerializer(serializers.ModelSerializer):
    openedAt = serializers.DateTimeField(source="opened_at")
    resolvedAt = serializers.DateTimeField(source="resolved_at", required=False, allow_null=True)
    class Meta:
        model = TradeDispute
        fields = [
            "id",
            "status",
            "reason",
            "description",
            "resolution",
            "openedAt",
            "resolvedAt",
            "transaction",
            "opened_by",
            "resolved_by",
        ]
        read_only_fields = ["id"]
