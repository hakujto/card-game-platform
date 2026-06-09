from rest_framework import viewsets, filters
from rest_framework.decorators import action
from django_filters.rest_framework import DjangoFilterBackend
from .models import Product, Order, OrderItem, Coupon, TradeListing, TradeBid, TradeTransaction, CardPriceHistory, TradeDispute
from .serializers import ProductSerializer, OrderSerializer, OrderItemSerializer, CouponSerializer, TradeListingSerializer, TradeBidSerializer, TradeTransactionSerializer, CardPriceHistorySerializer, TradeDisputeSerializer


class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.select_related().all()
    serializer_class = ProductSerializer
    http_method_names = ['options', 'head', 'get', 'post', 'put', 'patch']
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "description"]
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
    http_method_names = ['options', 'head', 'get', 'post', 'patch']
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status", "currency", "payment_method"]
    filterset_fields = ["status", "payment_method", "player", "coupon"]
    ordering_fields = "__all__"

    def get_object(self):
        obj = super().get_object()
        if obj.player_id != self.request.user.id:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("You do not own this resource.")
        return obj

    @action(detail=True, methods=["delete"], url_path="cancel")
    def cancel(self, request, pk=None):
        instance = self.get_object()
        result = instance.cancel()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="pay")
    def pay(self, request, pk=None):
        instance = self.get_object()
        if not (instance.status == "Pending"):
            from rest_framework.exceptions import ValidationError
            raise ValidationError({"detail": "Guard condition not met for pay"})
        payment_ref = request.data.get("payment_ref")
        result = instance.pay(payment_ref)
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["post"], url_path="process-payment")
    def process_payment(self, request, pk=None):
        instance = self.get_object()
        result = instance.process_payment()
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

    @action(detail=True, methods=["patch"], url_path="transitions/pending-to-paid")
    def transition_pending_to_paid(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Paid" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Paid not allowed"}, status=409)
        try:
            if instance.payment_method is None:
                raise DjangoValidationError({"payment_method": "payment_method is required for Pending -> Paid"})
            instance.status = "Paid"
            instance.process_payment()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/paid-to-processing")
    def transition_paid_to_processing(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Processing" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Processing not allowed"}, status=409)
        try:
            instance.status = "Processing"
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/processing-to-shipped")
    def transition_processing_to_shipped(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Shipped" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Shipped not allowed"}, status=409)
        try:
            if instance.tracking_number is None:
                raise DjangoValidationError({"tracking_number": "tracking_number is required for Processing -> Shipped"})
            instance.status = "Shipped"
            # TODO: instance.notify_shipped()  # @after stub
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/shipped-to-completed")
    def transition_shipped_to_completed(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Completed" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Completed not allowed"}, status=409)
        try:
            instance.status = "Completed"
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/pending-to-cancelled")
    def transition_pending_to_cancelled(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Cancelled" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Cancelled not allowed"}, status=409)
        try:
            instance.status = "Cancelled"
            instance.cancel()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/paid-to-cancelled")
    def transition_paid_to_cancelled(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Cancelled" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Cancelled not allowed"}, status=409)
        try:
            instance.status = "Cancelled"
            instance.cancel()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/completed-to-refunded")
    def transition_completed_to_refunded(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Refunded" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Refunded not allowed"}, status=409)
        try:
            instance.status = "Refunded"
            instance.refund()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/refunded-to-completed")
    def transition_refunded_to_completed(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        return Response({"error": "Transition Refunded -> Completed is not allowed"}, status=409)

    @action(detail=True, methods=["patch"], url_path="transitions/completed-to-cancelled")
    def transition_completed_to_cancelled(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        return Response({"error": "Transition Completed -> Cancelled is not allowed"}, status=409)

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
    http_method_names = ['options', 'head', 'get', 'post', 'delete']
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
    http_method_names = ['options', 'head', 'get', 'post', 'put', 'patch']
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["code"]
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
        if not (instance.is_active is True):
            from rest_framework.exceptions import ValidationError
            raise ValidationError({"detail": "Guard condition not met for redeem"})
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
    http_method_names = ['options', 'head', 'get', 'post', 'patch']
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["description"]
    filterset_fields = ["status", "listing_type", "condition", "seller", "card"]
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
        if not (instance.status == "Active"):
            from rest_framework.exceptions import ValidationError
            raise ValidationError({"detail": "Guard condition not met for cancel"})
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

    @action(detail=True, methods=["patch"], url_path="transitions/pending-to-active")
    def transition_pending_to_active(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Active" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Active not allowed"}, status=409)
        try:
            if instance.quantity is None:
                raise DjangoValidationError({"quantity": "quantity is required for Pending -> Active"})
            instance.status = "Active"
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/active-to-sold")
    def transition_active_to_sold(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Sold" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Sold not allowed"}, status=409)
        try:
            instance.status = "Sold"
            instance.finalize_auction()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/active-to-expired")
    def transition_active_to_expired(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Expired" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Expired not allowed"}, status=409)
        try:
            instance.status = "Expired"
            instance.close()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/active-to-cancelled")
    def transition_active_to_cancelled(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Cancelled" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Cancelled not allowed"}, status=409)
        try:
            instance.status = "Cancelled"
            instance.cancel()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/sold-to-active")
    def transition_sold_to_active(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        return Response({"error": "Transition Sold -> Active is not allowed"}, status=409)

    @action(detail=True, methods=["patch"], url_path="transitions/expired-to-active")
    def transition_expired_to_active(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        return Response({"error": "Transition Expired -> Active is not allowed"}, status=409)

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
    http_method_names = ['options', 'head', 'get', 'post']
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
    http_method_names = ['options', 'head', 'get']
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
    http_method_names = ['options', 'head', 'get']
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
    http_method_names = ['options', 'head', 'get', 'post', 'patch']
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status", "reason", "description"]
    filterset_fields = ["status", "reason", "transaction", "opened_by", "resolved_by"]
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

    @action(detail=True, methods=["post"], url_path="close")
    def close_resolved(self, request, pk=None):
        instance = self.get_object()
        result = instance.close_resolved()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="review")
    def review(self, request, pk=None):
        instance = self.get_object()
        result = instance.review()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["patch"], url_path="transitions/open-to-underreview")
    def transition_open_to_underreview(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "UnderReview" not in allowed:
            return Response({"error": f"Transition {instance.status} -> UnderReview not allowed"}, status=409)
        try:
            instance.status = "UnderReview"
            instance.review()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/underreview-to-resolved")
    def transition_underreview_to_resolved(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Resolved" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Resolved not allowed"}, status=409)
        try:
            if instance.resolution is None:
                raise DjangoValidationError({"resolution": "resolution is required for UnderReview -> Resolved"})
            instance.status = "Resolved"
            instance.close_resolved()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/underreview-to-escalated")
    def transition_underreview_to_escalated(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Escalated" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Escalated not allowed"}, status=409)
        try:
            instance.status = "Escalated"
            instance.escalate()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/escalated-to-resolved")
    def transition_escalated_to_resolved(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Resolved" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Resolved not allowed"}, status=409)
        try:
            if instance.resolution is None:
                raise DjangoValidationError({"resolution": "resolution is required for Escalated -> Resolved"})
            instance.status = "Resolved"
            instance.close_resolved()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/resolved-to-open")
    def transition_resolved_to_open(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        return Response({"error": "Transition Resolved -> Open is not allowed"}, status=409)

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
