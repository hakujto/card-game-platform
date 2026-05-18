from rest_framework import viewsets, filters
from rest_framework.decorators import action
from django_filters.rest_framework import DjangoFilterBackend
from .models import Card, CardSet, CardRuling, CardAbility, Deck, DeckCard, DeckSideboardCard, DeckTag, DeckTagAssignment
from .serializers import CardSerializer, CardSetSerializer, CardRulingSerializer, CardAbilitySerializer, DeckSerializer, DeckCardSerializer, DeckSideboardCardSerializer, DeckTagSerializer, DeckTagAssignmentSerializer


class CardViewSet(viewsets.ModelViewSet):
    queryset = Card.objects.select_related().all()
    serializer_class = CardSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "card_type", "rarity"]
    filterset_fields = ["card_type", "rarity", "mana_colors", "legal_formats", "set"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="ban")
    def ban(self, request, pk=None):
        instance = self.get_object()
        result = instance.ban()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="unban")
    def unban(self, request, pk=None):
        instance = self.get_object()
        result = instance.unban()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="restrict")
    def restrict(self, request, pk=None):
        instance = self.get_object()
        result = instance.restrict()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="unrestrict")
    def unrestrict(self, request, pk=None):
        instance = self.get_object()
        result = instance.unrestrict()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="value")
    def calculate_value(self, request, pk=None):
        instance = self.get_object()
        result = instance.calculate_value()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["post"], url_path="rarity-bonus")
    def apply_rarity_bonus(self, request, pk=None):
        instance = self.get_object()
        multiplier = request.data.get("multiplier")
        result = instance.apply_rarity_bonus(multiplier)
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["get"], url_path="legal")
    def is_legal_in_format(self, request, pk=None):
        instance = self.get_object()
        result = instance.is_legal_in_format(format)
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


class CardSetViewSet(viewsets.ModelViewSet):
    queryset = CardSet.objects.select_related().all()
    serializer_class = CardSetSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "code", "set_type"]
    filterset_fields = ["set_type"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["get"], url_path="standard-legal")
    def is_legal_in_standard(self, request, pk=None):
        instance = self.get_object()
        result = instance.is_legal_in_standard()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["get"], url_path="legal")
    def is_legal_in_format(self, request, pk=None):
        instance = self.get_object()
        result = instance.is_legal_in_format(format)
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["get"], url_path="rarity-count")
    def card_count_by_rarity(self, request, pk=None):
        instance = self.get_object()
        result = instance.card_count_by_rarity(rarity)
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["post"], url_path="rotate")
    def rotate_out(self, request, pk=None):
        instance = self.get_object()
        result = instance.rotate_out()
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


class CardRulingViewSet(viewsets.ModelViewSet):
    queryset = CardRuling.objects.select_related().all()
    serializer_class = CardRulingSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["ruling_text", "source"]
    filterset_fields = ["card"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["get"], url_path="current")
    def is_current(self, request, pk=None):
        instance = self.get_object()
        result = instance.is_current()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["get"], url_path="supersedes")
    def supersedes_previous(self, request, pk=None):
        instance = self.get_object()
        result = instance.supersedes_previous()
        from rest_framework.response import Response
        return Response({"result": result})


class CardAbilityViewSet(viewsets.ModelViewSet):
    queryset = CardAbility.objects.select_related().all()
    serializer_class = CardAbilitySerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["ability_type", "keyword", "ability_text"]
    filterset_fields = ["ability_type", "timing", "card"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["get"], url_path="usable")
    def is_usable_at(self, request, pk=None):
        instance = self.get_object()
        result = instance.is_usable_at(timing)
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["get"], url_path="describe")
    def describe(self, request, pk=None):
        instance = self.get_object()
        result = instance.describe()
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


class DeckViewSet(viewsets.ModelViewSet):
    queryset = Deck.objects.select_related().all()
    serializer_class = DeckSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "description", "format"]
    filterset_fields = ["format", "archetype", "player"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["get"], url_path="validate")
    def validate_size(self, request, pk=None):
        instance = self.get_object()
        result = instance.validate_size()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["post"], url_path="cards")
    def add_card(self, request, pk=None):
        instance = self.get_object()
        card_id = request.data.get("card_id")
        quantity = request.data.get("quantity")
        result = instance.add_card(card_id, quantity)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["delete"], url_path="cards/<int:card_id>")
    def remove_card(self, request, pk=None, card_id=None):
        instance = self.get_object()
        result = instance.remove_card(card_id)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="win-rate")
    def win_rate(self, request, pk=None):
        instance = self.get_object()
        result = instance.win_rate()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["post"], url_path="clone")
    def clone(self, request, pk=None):
        instance = self.get_object()
        result = instance.clone()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["post"], url_path="publish")
    def publish(self, request, pk=None):
        instance = self.get_object()
        result = instance.publish()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="unpublish")
    def unpublish(self, request, pk=None):
        instance = self.get_object()
        result = instance.unpublish()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="certify")
    def certify_tournament_legal(self, request, pk=None):
        instance = self.get_object()
        result = instance.certify_tournament_legal()
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


class DeckCardViewSet(viewsets.ModelViewSet):
    queryset = DeckCard.objects.select_related().all()
    serializer_class = DeckCardSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["deck", "card"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["patch"], url_path="increment")
    def increment(self, request, pk=None):
        instance = self.get_object()
        amount = request.data.get("amount")
        result = instance.increment(amount)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["patch"], url_path="decrement")
    def decrement(self, request, pk=None):
        instance = self.get_object()
        amount = request.data.get("amount")
        result = instance.decrement(amount)
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


class DeckSideboardCardViewSet(viewsets.ModelViewSet):
    queryset = DeckSideboardCard.objects.select_related().all()
    serializer_class = DeckSideboardCardSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["deck", "card"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["patch"], url_path="increment")
    def increment(self, request, pk=None):
        instance = self.get_object()
        amount = request.data.get("amount")
        result = instance.increment(amount)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["patch"], url_path="decrement")
    def decrement(self, request, pk=None):
        instance = self.get_object()
        amount = request.data.get("amount")
        result = instance.decrement(amount)
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


class DeckTagViewSet(viewsets.ModelViewSet):
    queryset = DeckTag.objects.select_related().all()
    serializer_class = DeckTagSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "color"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["patch"], url_path="rename")
    def rename(self, request, pk=None):
        instance = self.get_object()
        new_name = request.data.get("new_name")
        result = instance.rename(new_name)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="merge")
    def merge_into(self, request, pk=None):
        instance = self.get_object()
        target_tag_id = request.data.get("target_tag_id")
        result = instance.merge_into(target_tag_id)
        from rest_framework.response import Response
        return Response(status=204)


class DeckTagAssignmentViewSet(viewsets.ModelViewSet):
    queryset = DeckTagAssignment.objects.select_related().all()
    serializer_class = DeckTagAssignmentSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["deck", "tag"]
    ordering_fields = "__all__"
