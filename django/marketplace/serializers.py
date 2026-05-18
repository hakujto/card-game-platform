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
            "created_at",
            "paid_at",
            "shipped_at",
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
    class Meta:
        model = TradeListing
        fields = [
            "id",
            "listing_type",
            "asking_price",
            "auction_start_price",
            "auction_current_bid",
            "auction_end_time",
            "foil",
            "condition",
            "quantity",
            "status",
            "description",
            "created_at",
            "expires_at",
            "seller",
            "card",
        ]
        read_only_fields = ["id"]


class TradeBidSerializer(serializers.ModelSerializer):
    class Meta:
        model = TradeBid
        fields = [
            "id",
            "amount",
            "placed_at",
            "is_winning",
            "listing",
            "bidder",
        ]
        read_only_fields = ["id"]


class TradeTransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = TradeTransaction
        fields = [
            "id",
            "final_price",
            "platform_fee",
            "status",
            "completed_at",
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
    class Meta:
        model = TradeDispute
        fields = [
            "id",
            "reason",
            "description",
            "status",
            "resolution",
            "opened_at",
            "resolved_at",
            "transaction",
            "opened_by",
            "resolved_by",
        ]
        read_only_fields = ["id"]
