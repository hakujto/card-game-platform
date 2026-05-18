from rest_framework import viewsets, filters
from rest_framework.decorators import action
from django_filters.rest_framework import DjangoFilterBackend
from .models import Season, Tournament, TournamentJudge, TournamentRegistration, TournamentRound, Match, Game, TournamentPrize, AwardedPrize
from .serializers import SeasonSerializer, TournamentSerializer, TournamentJudgeSerializer, TournamentRegistrationSerializer, TournamentRoundSerializer, MatchSerializer, GameSerializer, TournamentPrizeSerializer, AwardedPrizeSerializer


class SeasonViewSet(viewsets.ModelViewSet):
    queryset = Season.objects.select_related().all()
    serializer_class = SeasonSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "format", "reward_description"]
    filterset_fields = ["format"]
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

    @action(detail=True, methods=["post"], url_path="finalize")
    def finalize_rewards(self, request, pk=None):
        instance = self.get_object()
        result = instance.finalize_rewards()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="ongoing")
    def is_ongoing(self, request, pk=None):
        instance = self.get_object()
        result = instance.is_ongoing()
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


class TournamentViewSet(viewsets.ModelViewSet):
    queryset = Tournament.objects.select_related().all()
    serializer_class = TournamentSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "description", "format"]
    filterset_fields = ["format", "tournament_type", "status", "season", "organizer"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="start")
    def start(self, request, pk=None):
        instance = self.get_object()
        result = instance.start()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="cancel")
    def cancel(self, request, pk=None):
        instance = self.get_object()
        result = instance.cancel()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="complete")
    def complete(self, request, pk=None):
        instance = self.get_object()
        result = instance.complete()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="rounds")
    def generate_round(self, request, pk=None):
        instance = self.get_object()
        result = instance.generate_round()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="prizes")
    def calculate_prize_distribution(self, request, pk=None):
        instance = self.get_object()
        result = instance.calculate_prize_distribution()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["post"], url_path="register")
    def register_player(self, request, pk=None):
        instance = self.get_object()
        player_id = request.data.get("player_id")
        deck_id = request.data.get("deck_id")
        result = instance.register_player(player_id, deck_id)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="full")
    def is_full(self, request, pk=None):
        instance = self.get_object()
        result = instance.is_full()
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


class TournamentJudgeViewSet(viewsets.ModelViewSet):
    queryset = TournamentJudge.objects.select_related().all()
    serializer_class = TournamentJudgeSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["role"]
    filterset_fields = ["role", "tournament", "player"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="promote")
    def promote_to_head(self, request, pk=None):
        instance = self.get_object()
        result = instance.promote_to_head()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["delete"], url_path="remove")
    def remove(self, request, pk=None):
        instance = self.get_object()
        result = instance.remove()
        from rest_framework.response import Response
        return Response(status=204)


class TournamentRegistrationViewSet(viewsets.ModelViewSet):
    queryset = TournamentRegistration.objects.select_related().all()
    serializer_class = TournamentRegistrationSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status"]
    filterset_fields = ["status", "tournament", "player", "deck"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="withdraw")
    def withdraw(self, request, pk=None):
        instance = self.get_object()
        result = instance.withdraw()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="disqualify")
    def disqualify(self, request, pk=None):
        instance = self.get_object()
        reason = request.data.get("reason")
        result = instance.disqualify(reason)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="promote")
    def promote_from_waitlist(self, request, pk=None):
        instance = self.get_object()
        result = instance.promote_from_waitlist()
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


class TournamentRoundViewSet(viewsets.ModelViewSet):
    queryset = TournamentRound.objects.select_related().all()
    serializer_class = TournamentRoundSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status"]
    filterset_fields = ["status", "tournament"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="start")
    def start(self, request, pk=None):
        instance = self.get_object()
        result = instance.start()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="complete")
    def complete(self, request, pk=None):
        instance = self.get_object()
        result = instance.complete()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="pairings")
    def generate_pairings(self, request, pk=None):
        instance = self.get_object()
        result = instance.generate_pairings()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="time-expired")
    def is_time_expired(self, request, pk=None):
        instance = self.get_object()
        result = instance.is_time_expired()
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


class MatchViewSet(viewsets.ModelViewSet):
    queryset = Match.objects.select_related().all()
    serializer_class = MatchSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status", "result_notes"]
    filterset_fields = ["status", "round", "player1", "player2"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="record")
    def record_result(self, request, pk=None):
        instance = self.get_object()
        p1_wins = request.data.get("p1_wins")
        p2_wins = request.data.get("p2_wins")
        result = instance.record_result(p1_wins, p2_wins)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="winner")
    def determine_winner(self, request, pk=None):
        instance = self.get_object()
        result = instance.determine_winner()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["post"], url_path="concede")
    def concede(self, request, pk=None):
        instance = self.get_object()
        player_id = request.data.get("player_id")
        result = instance.concede(player_id)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="draw")
    def draw(self, request, pk=None):
        instance = self.get_object()
        result = instance.draw()
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


class GameViewSet(viewsets.ModelViewSet):
    queryset = Game.objects.select_related().all()
    serializer_class = GameSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["winner_side", "ended_by"]
    filterset_fields = ["winner_side", "ended_by", "match", "winner"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="winner")
    def record_winner(self, request, pk=None):
        instance = self.get_object()
        winner_side = request.data.get("winner_side")
        result = instance.record_winner(winner_side)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="duration")
    def duration_minutes(self, request, pk=None):
        instance = self.get_object()
        result = instance.duration_minutes()
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


class TournamentPrizeViewSet(viewsets.ModelViewSet):
    queryset = TournamentPrize.objects.select_related().all()
    serializer_class = TournamentPrizeSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["prize_type", "description"]
    filterset_fields = ["prize_type", "tournament"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["get"], url_path="applies")
    def applies_to_placement(self, request, pk=None):
        instance = self.get_object()
        result = instance.applies_to_placement(placement)
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["post"], url_path="award")
    def award_to_player(self, request, pk=None):
        instance = self.get_object()
        player_id = request.data.get("player_id")
        result = instance.award_to_player(player_id)
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


class AwardedPrizeViewSet(viewsets.ModelViewSet):
    queryset = AwardedPrize.objects.select_related().all()
    serializer_class = AwardedPrizeSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["prize", "player"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="claim")
    def claim(self, request, pk=None):
        instance = self.get_object()
        result = instance.claim()
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
