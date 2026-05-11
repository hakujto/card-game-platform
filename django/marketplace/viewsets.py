from rest_framework import viewsets, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Product, Order, OrderItem, Coupon, Tradelisting, TradeBid, TradeTransaction, CardPriceHistory, TradeDispute
from .serializers import ProductSerializer, OrderSerializer, OrderItemSerializer, CouponSerializer, TradelistingSerializer, TradeBidSerializer, TradeTransactionSerializer, CardPriceHistorySerializer, TradeDisputeSerializer


class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.select_related().all()
    serializer_class = ProductSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "product_type", "description"]
    filterset_fields = ["product_type", "card", "card_set"]
    ordering_fields = "__all__"


class OrderViewSet(viewsets.ModelViewSet):
    queryset = Order.objects.select_related().all()
    serializer_class = OrderSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status", "currency", "payment_method"]
    filterset_fields = ["status", "payment_method", "player", "coupon"]
    ordering_fields = "__all__"


class OrderItemViewSet(viewsets.ModelViewSet):
    queryset = OrderItem.objects.select_related().all()
    serializer_class = OrderItemSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["order", "product"]
    ordering_fields = "__all__"


class CouponViewSet(viewsets.ModelViewSet):
    queryset = Coupon.objects.select_related().all()
    serializer_class = CouponSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["code", "discount_type"]
    filterset_fields = ["discount_type"]
    ordering_fields = "__all__"


class TradelistingViewSet(viewsets.ModelViewSet):
    queryset = Tradelisting.objects.select_related().all()
    serializer_class = TradelistingSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["listing_type", "condition", "status"]
    filterset_fields = ["listing_type", "condition", "status", "seller", "card"]
    ordering_fields = "__all__"


class TradeBidViewSet(viewsets.ModelViewSet):
    queryset = TradeBid.objects.select_related().all()
    serializer_class = TradeBidSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["listing", "bidder"]
    ordering_fields = "__all__"


class TradeTransactionViewSet(viewsets.ModelViewSet):
    queryset = TradeTransaction.objects.select_related().all()
    serializer_class = TradeTransactionSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status"]
    filterset_fields = ["status", "listing", "buyer", "seller"]
    ordering_fields = "__all__"


class CardPriceHistoryViewSet(viewsets.ModelViewSet):
    queryset = CardPriceHistory.objects.select_related().all()
    serializer_class = CardPriceHistorySerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["card"]
    ordering_fields = "__all__"


class TradeDisputeViewSet(viewsets.ModelViewSet):
    queryset = TradeDispute.objects.select_related().all()
    serializer_class = TradeDisputeSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["reason", "description", "status"]
    filterset_fields = ["reason", "status", "transaction", "opened_by", "resolved_by"]
    ordering_fields = "__all__"
