from rest_framework import viewsets, filters
from rest_framework.decorators import action
from django_filters.rest_framework import DjangoFilterBackend
from .models import Product, Order, OrderItem, Coupon, TradeListing, TradeBid, TradeTransaction, CardPriceHistory, TradeDispute
from .serializers import ProductSerializer, OrderSerializer, OrderItemSerializer, CouponSerializer, TradeListingSerializer, TradeBidSerializer, TradeTransactionSerializer, CardPriceHistorySerializer, TradeDisputeSerializer


class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.select_related().all()
    serializer_class = ProductSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "product_type", "description"]
    filterset_fields = ["product_type", "card", "card_set"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="activate")
    def activate(self, request, pk=None):
        instance = self.get_object()
        result = instance.activate()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="deactivate")
    def deactivate(self, request, pk=None):
        instance = self.get_object()
        result = instance.deactivate()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["patch"], url_path="discount")
    def apply_discount(self, request, pk=None):
        instance = self.get_object()
        percent = request.data.get("percent")
        result = instance.apply_discount(percent)
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["post"], url_path="restock")
    def restock(self, request, pk=None):
        instance = self.get_object()
        quantity = request.data.get("quantity")
        result = instance.restock(quantity)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="effective-price")
    def effective_price(self, request, pk=None):
        instance = self.get_object()
        result = instance.effective_price()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["get"], url_path="in-stock")
    def is_in_stock(self, request, pk=None):
        instance = self.get_object()
        result = instance.is_in_stock()
        from rest_framework.response import Response
        return Response({"result": result})

    def _validate_instance(self, instance):
        from rest_framework.exceptions import ValidationError
        from django.core.exceptions import ValidationError as DjangoValidationError
        try:
            instance.full_clean()
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict)

    def perform_create(self, serializer):
        from django.db import transaction
        with transaction.atomic():
            instance = serializer.save()
            self._validate_instance(instance)

    def perform_update(self, serializer):
        from django.db import transaction
        with transaction.atomic():
            instance = serializer.save()
            self._validate_instance(instance)


class OrderViewSet(viewsets.ModelViewSet):
    queryset = Order.objects.select_related().all()
    serializer_class = OrderSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status", "currency", "payment_method"]
    filterset_fields = ["status", "payment_method", "player", "coupon"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["delete"], url_path="cancel")
    def cancel(self, request, pk=None):
        instance = self.get_object()
        result = instance.cancel()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="pay")
    def pay(self, request, pk=None):
        instance = self.get_object()
        payment_ref = request.data.get("payment_ref")
        result = instance.pay(payment_ref)
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["get"], url_path="total")
    def calculate_total(self, request, pk=None):
        instance = self.get_object()
        result = instance.calculate_total()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["patch"], url_path="discount")
    def apply_discount(self, request, pk=None):
        instance = self.get_object()
        percent = request.data.get("percent")
        result = instance.apply_discount(percent)
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["post"], url_path="refund")
    def refund(self, request, pk=None):
        instance = self.get_object()
        result = instance.refund()
        from rest_framework.response import Response
        return Response(status=204)

    def _validate_instance(self, instance):
        from rest_framework.exceptions import ValidationError
        from django.core.exceptions import ValidationError as DjangoValidationError
        try:
            instance.full_clean()
            instance.validate_implies()
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict)

    def perform_create(self, serializer):
        from django.db import transaction
        with transaction.atomic():
            instance = serializer.save()
            self._validate_instance(instance)

    def perform_update(self, serializer):
        from django.db import transaction
        with transaction.atomic():
            instance = serializer.save()
            self._validate_instance(instance)


class OrderItemViewSet(viewsets.ModelViewSet):
    queryset = OrderItem.objects.select_related().all()
    serializer_class = OrderItemSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["order", "product"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["get"], url_path="total")
    def line_total(self, request, pk=None):
        instance = self.get_object()
        result = instance.line_total()
        from rest_framework.response import Response
        return Response({"result": result})

    def _validate_instance(self, instance):
        from rest_framework.exceptions import ValidationError
        from django.core.exceptions import ValidationError as DjangoValidationError
        try:
            instance.full_clean()
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict)

    def perform_create(self, serializer):
        from django.db import transaction
        with transaction.atomic():
            instance = serializer.save()
            self._validate_instance(instance)

    def perform_update(self, serializer):
        from django.db import transaction
        with transaction.atomic():
            instance = serializer.save()
            self._validate_instance(instance)


class CouponViewSet(viewsets.ModelViewSet):
    queryset = Coupon.objects.select_related().all()
    serializer_class = CouponSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["code", "discount_type"]
    filterset_fields = ["discount_type"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["get"], url_path="valid")
    def is_valid(self, request, pk=None):
        instance = self.get_object()
        result = instance.is_valid()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["get"], url_path="applicable")
    def is_applicable_to_order(self, request, pk=None):
        instance = self.get_object()
        result = instance.is_applicable_to_order(order_total)
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["post"], url_path="redeem")
    def redeem(self, request, pk=None):
        instance = self.get_object()
        result = instance.redeem()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="deactivate")
    def deactivate(self, request, pk=None):
        instance = self.get_object()
        result = instance.deactivate()
        from rest_framework.response import Response
        return Response(status=204)

    def _validate_instance(self, instance):
        from rest_framework.exceptions import ValidationError
        from django.core.exceptions import ValidationError as DjangoValidationError
        try:
            instance.full_clean()
            instance.validate_implies()
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict)

    def perform_create(self, serializer):
        from django.db import transaction
        with transaction.atomic():
            instance = serializer.save()
            self._validate_instance(instance)

    def perform_update(self, serializer):
        from django.db import transaction
        with transaction.atomic():
            instance = serializer.save()
            self._validate_instance(instance)


class TradeListingViewSet(viewsets.ModelViewSet):
    queryset = TradeListing.objects.select_related().all()
    serializer_class = TradeListingSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["listing_type", "condition", "status"]
    filterset_fields = ["listing_type", "condition", "status", "seller", "card"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="close")
    def close(self, request, pk=None):
        instance = self.get_object()
        result = instance.close()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["patch"], url_path="extend")
    def extend(self, request, pk=None):
        instance = self.get_object()
        days = request.data.get("days")
        result = instance.extend(days)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["delete"], url_path="cancel")
    def cancel(self, request, pk=None):
        instance = self.get_object()
        result = instance.cancel()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="expired")
    def is_expired(self, request, pk=None):
        instance = self.get_object()
        result = instance.is_expired()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["post"], url_path="finalize")
    def finalize_auction(self, request, pk=None):
        instance = self.get_object()
        result = instance.finalize_auction()
        from rest_framework.response import Response
        return Response(status=204)

    def _validate_instance(self, instance):
        from rest_framework.exceptions import ValidationError
        from django.core.exceptions import ValidationError as DjangoValidationError
        try:
            instance.full_clean()
            instance.validate_implies()
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict)

    def perform_create(self, serializer):
        from django.db import transaction
        with transaction.atomic():
            instance = serializer.save()
            self._validate_instance(instance)

    def perform_update(self, serializer):
        from django.db import transaction
        with transaction.atomic():
            instance = serializer.save()
            self._validate_instance(instance)


class TradeBidViewSet(viewsets.ModelViewSet):
    queryset = TradeBid.objects.select_related().all()
    serializer_class = TradeBidSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["listing", "bidder"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["get"], url_path="outbid")
    def outbid_by(self, request, pk=None):
        instance = self.get_object()
        result = instance.outbid_by(new_amount)
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["delete"], url_path="retract")
    def retract(self, request, pk=None):
        instance = self.get_object()
        result = instance.retract()
        from rest_framework.response import Response
        return Response(status=204)

    def _validate_instance(self, instance):
        from rest_framework.exceptions import ValidationError
        from django.core.exceptions import ValidationError as DjangoValidationError
        try:
            instance.full_clean()
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict)

    def perform_create(self, serializer):
        from django.db import transaction
        with transaction.atomic():
            instance = serializer.save()
            self._validate_instance(instance)

    def perform_update(self, serializer):
        from django.db import transaction
        with transaction.atomic():
            instance = serializer.save()
            self._validate_instance(instance)


class TradeTransactionViewSet(viewsets.ModelViewSet):
    queryset = TradeTransaction.objects.select_related().all()
    serializer_class = TradeTransactionSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status"]
    filterset_fields = ["status", "listing", "buyer", "seller"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="complete")
    def complete(self, request, pk=None):
        instance = self.get_object()
        result = instance.complete()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="refund")
    def refund(self, request, pk=None):
        instance = self.get_object()
        result = instance.refund()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="dispute")
    def open_dispute(self, request, pk=None):
        instance = self.get_object()
        reason = request.data.get("reason")
        result = instance.open_dispute(reason)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="seller-net")
    def seller_net(self, request, pk=None):
        instance = self.get_object()
        result = instance.seller_net()
        from rest_framework.response import Response
        return Response({"result": result})

    def _validate_instance(self, instance):
        from rest_framework.exceptions import ValidationError
        from django.core.exceptions import ValidationError as DjangoValidationError
        try:
            instance.full_clean()
            instance.validate_implies()
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict)

    def perform_create(self, serializer):
        from django.db import transaction
        with transaction.atomic():
            instance = serializer.save()
            self._validate_instance(instance)

    def perform_update(self, serializer):
        from django.db import transaction
        with transaction.atomic():
            instance = serializer.save()
            self._validate_instance(instance)


class CardPriceHistoryViewSet(viewsets.ModelViewSet):
    queryset = CardPriceHistory.objects.select_related().all()
    serializer_class = CardPriceHistorySerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["card"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["get"], url_path="change")
    def price_change_percent(self, request, pk=None):
        instance = self.get_object()
        result = instance.price_change_percent(previous_avg)
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["get"], url_path="spike")
    def is_price_spike(self, request, pk=None):
        instance = self.get_object()
        result = instance.is_price_spike(threshold_percent)
        from rest_framework.response import Response
        return Response({"result": result})

    def _validate_instance(self, instance):
        from rest_framework.exceptions import ValidationError
        from django.core.exceptions import ValidationError as DjangoValidationError
        try:
            instance.full_clean()
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict)

    def perform_create(self, serializer):
        from django.db import transaction
        with transaction.atomic():
            instance = serializer.save()
            self._validate_instance(instance)

    def perform_update(self, serializer):
        from django.db import transaction
        with transaction.atomic():
            instance = serializer.save()
            self._validate_instance(instance)


class TradeDisputeViewSet(viewsets.ModelViewSet):
    queryset = TradeDispute.objects.select_related().all()
    serializer_class = TradeDisputeSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["reason", "description", "status"]
    filterset_fields = ["reason", "status", "transaction", "opened_by", "resolved_by"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="escalate")
    def escalate(self, request, pk=None):
        instance = self.get_object()
        result = instance.escalate()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="resolve")
    def resolve(self, request, pk=None):
        instance = self.get_object()
        resolution_text = request.data.get("resolution_text")
        result = instance.resolve(resolution_text)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="review")
    def review(self, request, pk=None):
        instance = self.get_object()
        result = instance.review()
        from rest_framework.response import Response
        return Response(status=204)

    def _validate_instance(self, instance):
        from rest_framework.exceptions import ValidationError
        from django.core.exceptions import ValidationError as DjangoValidationError
        try:
            instance.full_clean()
            instance.validate_implies()
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict)

    def perform_create(self, serializer):
        from django.db import transaction
        with transaction.atomic():
            instance = serializer.save()
            self._validate_instance(instance)

    def perform_update(self, serializer):
        from django.db import transaction
        with transaction.atomic():
            instance = serializer.save()
            self._validate_instance(instance)
