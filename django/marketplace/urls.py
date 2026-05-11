from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .viewsets import ProductViewSet, OrderViewSet, OrderItemViewSet, CouponViewSet, TradelistingViewSet, TradeBidViewSet, TradeTransactionViewSet, CardPriceHistoryViewSet, TradeDisputeViewSet

router = DefaultRouter()
router.register(r"products", ProductViewSet, basename="product")
router.register(r"orders", OrderViewSet, basename="order")
router.register(r"order_items", OrderItemViewSet, basename="order_item")
router.register(r"coupons", CouponViewSet, basename="coupon")
router.register(r"tradelistings", TradelistingViewSet, basename="tradelisting")
router.register(r"trade_bids", TradeBidViewSet, basename="trade_bid")
router.register(r"trade_transactions", TradeTransactionViewSet, basename="trade_transaction")
router.register(r"card_price_histories", CardPriceHistoryViewSet, basename="card_price_history")
router.register(r"trade_disputes", TradeDisputeViewSet, basename="trade_dispute")

urlpatterns = [
    path("", include(router.urls)),
]
