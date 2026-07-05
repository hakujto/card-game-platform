from django.contrib import admin
from .models import Product, Order, OrderItem, Coupon, TradeListing, TradeBid, TradeTransaction, CardPriceHistory, TradeDispute


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ["id", "name", "product_type", "price", "stock"]
    search_fields = ["name", "product_type", "description"]
    list_filter = ["product_type", "card", "card_set"]


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ["id", "status", "total", "discount_applied", "currency"]
    search_fields = ["status", "currency", "payment_method"]
    list_filter = ["status", "payment_method", "player", "coupon"]


@admin.register(OrderItem)
class OrderItemAdmin(admin.ModelAdmin):
    list_display = ["id", "quantity", "price_at_purchase", "foil", "order"]
    list_filter = ["order", "product"]


@admin.register(Coupon)
class CouponAdmin(admin.ModelAdmin):
    list_display = ["id", "code", "discount_type", "discount_value", "min_order_value"]
    search_fields = ["code", "discount_type"]
    list_filter = ["discount_type"]


@admin.register(TradeListing)
class TradeListingAdmin(admin.ModelAdmin):
    list_display = ["id", "public_id", "status", "listing_type", "asking_price"]
    search_fields = ["status", "listing_type", "condition"]
    list_filter = ["status", "listing_type", "condition", "seller", "card"]


@admin.register(TradeBid)
class TradeBidAdmin(admin.ModelAdmin):
    list_display = ["id", "amount", "placed_at", "is_winning", "listing"]
    list_filter = ["listing", "bidder"]


@admin.register(TradeTransaction)
class TradeTransactionAdmin(admin.ModelAdmin):
    list_display = ["id", "final_price", "platform_fee", "status", "completed_at"]
    search_fields = ["status"]
    list_filter = ["status", "listing", "buyer", "seller"]


@admin.register(CardPriceHistory)
class CardPriceHistoryAdmin(admin.ModelAdmin):
    list_display = ["id", "price_date", "avg_price", "min_price", "max_price"]
    list_filter = ["card"]


@admin.register(TradeDispute)
class TradeDisputeAdmin(admin.ModelAdmin):
    list_display = ["id", "status", "reason", "description", "resolution"]
    search_fields = ["status", "reason", "description"]
    list_filter = ["status", "reason", "transaction", "opened_by", "resolved_by"]
