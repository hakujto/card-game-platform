from rest_framework import viewsets, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Product, Order, OrderItem, Coupon, Tradelisting, TradeBid, TradeTransaction, CardPriceHistory, TradeDispute
from .serializers import ProductSerializer, OrderSerializer, OrderItemSerializer, CouponSerializer, TradelistingSerializer, TradeBidSerializer, TradeTransactionSerializer, CardPriceHistorySerializer, TradeDisputeSerializer


class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "product_type", "description"]
    filterset_fields = ["product_type", "card", "card_set"]


class OrderViewSet(viewsets.ModelViewSet):
    queryset = Order.objects.all()
    serializer_class = OrderSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status", "currency", "payment_method"]
    filterset_fields = ["status", "payment_method", "player", "items", "coupon"]


class OrderItemViewSet(viewsets.ModelViewSet):
    queryset = OrderItem.objects.all()
    serializer_class = OrderItemSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["order", "product"]


class CouponViewSet(viewsets.ModelViewSet):
    queryset = Coupon.objects.all()
    serializer_class = CouponSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["code", "discount_type"]
    filterset_fields = ["discount_type"]


class TradelistingViewSet(viewsets.ModelViewSet):
    queryset = Tradelisting.objects.all()
    serializer_class = TradelistingSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["listing_type", "condition", "status"]
    filterset_fields = ["listing_type", "condition", "status", "seller", "card"]


class TradeBidViewSet(viewsets.ModelViewSet):
    queryset = TradeBid.objects.all()
    serializer_class = TradeBidSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["listing", "bidder"]


class TradeTransactionViewSet(viewsets.ModelViewSet):
    queryset = TradeTransaction.objects.all()
    serializer_class = TradeTransactionSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status"]
    filterset_fields = ["status", "listing", "buyer", "seller"]


class CardPriceHistoryViewSet(viewsets.ModelViewSet):
    queryset = CardPriceHistory.objects.all()
    serializer_class = CardPriceHistorySerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["card"]


class TradeDisputeViewSet(viewsets.ModelViewSet):
    queryset = TradeDispute.objects.all()
    serializer_class = TradeDisputeSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["reason", "description", "status"]
    filterset_fields = ["reason", "status", "transaction", "opened_by", "resolved_by"]
