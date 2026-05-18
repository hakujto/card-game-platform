from rest_framework import viewsets, filters
from rest_framework.decorators import action
from django_filters.rest_framework import DjangoFilterBackend
from .models import Player, PlayerSeasonStats, PlayerCollection, Friendship, Achievement, PlayerAchievement, CraftingRecipe, CraftingIngredient
from .serializers import PlayerSerializer, PlayerSeasonStatsSerializer, PlayerCollectionSerializer, FriendshipSerializer, AchievementSerializer, PlayerAchievementSerializer, CraftingRecipeSerializer, CraftingIngredientSerializer


class PlayerViewSet(viewsets.ModelViewSet):
    queryset = Player.objects.select_related().all()
    serializer_class = PlayerSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["display_name", "rank", "bio"]
    filterset_fields = ["rank", "preferred_format", "user"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="promote")
    def promote(self, request, pk=None):
        instance = self.get_object()
        result = instance.promote()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["post"], url_path="demote")
    def demote(self, request, pk=None):
        instance = self.get_object()
        result = instance.demote()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["post"], url_path="win")
    def record_win(self, request, pk=None):
        instance = self.get_object()
        result = instance.record_win()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="loss")
    def record_loss(self, request, pk=None):
        instance = self.get_object()
        result = instance.record_loss()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="win-rate")
    def win_rate(self, request, pk=None):
        instance = self.get_object()
        result = instance.win_rate()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["post"], url_path="verify")
    def verify(self, request, pk=None):
        instance = self.get_object()
        result = instance.verify()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["patch"], url_path="rating")
    def update_rating(self, request, pk=None):
        instance = self.get_object()
        delta = request.data.get("delta")
        result = instance.update_rating(delta)
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


class PlayerSeasonStatsViewSet(viewsets.ModelViewSet):
    queryset = PlayerSeasonStats.objects.select_related().all()
    serializer_class = PlayerSeasonStatsSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["highest_rank"]
    filterset_fields = ["highest_rank", "player", "season"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["get"], url_path="win-rate")
    def win_rate(self, request, pk=None):
        instance = self.get_object()
        result = instance.win_rate()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["patch"], url_path="points")
    def add_points(self, request, pk=None):
        instance = self.get_object()
        points = request.data.get("points")
        result = instance.add_points(points)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="tournament-win")
    def record_tournament_win(self, request, pk=None):
        instance = self.get_object()
        result = instance.record_tournament_win()
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


class PlayerCollectionViewSet(viewsets.ModelViewSet):
    queryset = PlayerCollection.objects.select_related().all()
    serializer_class = PlayerCollectionSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["condition", "acquired_via"]
    filterset_fields = ["condition", "acquired_via", "player", "card"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="add")
    def add(self, request, pk=None):
        instance = self.get_object()
        quantity = request.data.get("quantity")
        result = instance.add(quantity)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="remove")
    def remove(self, request, pk=None):
        instance = self.get_object()
        quantity = request.data.get("quantity")
        result = instance.remove(quantity)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="value")
    def estimated_value(self, request, pk=None):
        instance = self.get_object()
        result = instance.estimated_value()
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


class FriendshipViewSet(viewsets.ModelViewSet):
    queryset = Friendship.objects.select_related().all()
    serializer_class = FriendshipSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status"]
    filterset_fields = ["status", "requester", "receiver"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="accept")
    def accept(self, request, pk=None):
        instance = self.get_object()
        result = instance.accept()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="decline")
    def decline(self, request, pk=None):
        instance = self.get_object()
        result = instance.decline()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="block")
    def block(self, request, pk=None):
        instance = self.get_object()
        result = instance.block()
        from rest_framework.response import Response
        return Response(status=204)


class AchievementViewSet(viewsets.ModelViewSet):
    queryset = Achievement.objects.select_related().all()
    serializer_class = AchievementSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "description", "rarity"]
    filterset_fields = ["rarity"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["get"], url_path="point-value")
    def point_value(self, request, pk=None):
        instance = self.get_object()
        result = instance.point_value(multiplier)
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["post"], url_path="reveal")
    def reveal(self, request, pk=None):
        instance = self.get_object()
        result = instance.reveal()
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


class PlayerAchievementViewSet(viewsets.ModelViewSet):
    queryset = PlayerAchievement.objects.select_related().all()
    serializer_class = PlayerAchievementSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["player", "achievement"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["patch"], url_path="progress")
    def increment_progress(self, request, pk=None):
        instance = self.get_object()
        amount = request.data.get("amount")
        result = instance.increment_progress(amount)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="complete")
    def complete(self, request, pk=None):
        instance = self.get_object()
        result = instance.complete()
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


class CraftingRecipeViewSet(viewsets.ModelViewSet):
    queryset = CraftingRecipe.objects.select_related().all()
    serializer_class = CraftingRecipeSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["result_card"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["get"], url_path="can-craft")
    def can_craft(self, request, pk=None):
        instance = self.get_object()
        result = instance.can_craft(player_id)
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["post"], url_path="craft")
    def execute_craft(self, request, pk=None):
        instance = self.get_object()
        player_id = request.data.get("player_id")
        result = instance.execute_craft(player_id)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="disable")
    def disable(self, request, pk=None):
        instance = self.get_object()
        result = instance.disable()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="enable")
    def enable(self, request, pk=None):
        instance = self.get_object()
        result = instance.enable()
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


class CraftingIngredientViewSet(viewsets.ModelViewSet):
    queryset = CraftingIngredient.objects.select_related().all()
    serializer_class = CraftingIngredientSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["recipe", "card"]
    ordering_fields = "__all__"
