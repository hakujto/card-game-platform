from rest_framework import viewsets, filters
from rest_framework.decorators import action
from django_filters.rest_framework import DjangoFilterBackend
from .models import Season, Tournament, TournamentJudge, TournamentRegistration, TournamentRound, Match, Game, TournamentPrize, AwardedPrize
from .serializers import SeasonSerializer, TournamentSerializer, TournamentJudgeSerializer, TournamentRegistrationSerializer, TournamentRoundSerializer, MatchSerializer, GameSerializer, TournamentPrizeSerializer, AwardedPrizeSerializer


class SeasonViewSet(viewsets.ModelViewSet):
    queryset = Season.objects.select_related().all()
    serializer_class = SeasonSerializer
    http_method_names = ['options', 'head', 'get', 'post', 'put', 'patch']
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name"]
    filterset_fields = ["format"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="activate")
    def activate(self, request, pk=None):
        if not hasattr(request.user, "role") or request.user.role not in ["admin"]:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("Insufficient role for activate")
        instance = self.get_object()
        result = instance.activate()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="deactivate")
    def deactivate(self, request, pk=None):
        if not hasattr(request.user, "role") or request.user.role not in ["admin"]:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("Insufficient role for deactivate")
        instance = self.get_object()
        result = instance.deactivate()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="finalize")
    def finalize_rewards(self, request, pk=None):
        if not hasattr(request.user, "role") or request.user.role not in ["admin"]:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("Insufficient role for finalize_rewards")
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
    http_method_names = ['options', 'head', 'get', 'post', 'put', 'patch']
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "description"]
    filterset_fields = ["status", "format", "tournament_type", "season", "organizer"]
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

    @action(detail=True, methods=["patch"], url_path="transitions/draft-to-registration")
    def transition_draft_to_registration(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_queryset().get(pk=pk)
        if not hasattr(request.user, "role") or request.user.role not in ["Admin", "Organizer"]:
            raise PermissionDenied("Insufficient role for transition Draft -> Registration")
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Registration" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Registration not allowed"}, status=409)
        try:
            if instance.name is None:
                raise DjangoValidationError({"name": "name is required for Draft -> Registration"})
            if instance.start_time is None:
                raise DjangoValidationError({"start_time": "start_time is required for Draft -> Registration"})
            instance.status = "Registration"
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/registration-to-ongoing")
    def transition_registration_to_ongoing(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_queryset().get(pk=pk)
        if not hasattr(request.user, "role") or request.user.role not in ["Admin", "Organizer"]:
            raise PermissionDenied("Insufficient role for transition Registration -> Ongoing")
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Ongoing" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Ongoing not allowed"}, status=409)
        try:
            instance.status = "Ongoing"
            instance.start()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/registration-to-cancelled")
    def transition_registration_to_cancelled(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_queryset().get(pk=pk)
        if not hasattr(request.user, "role") or request.user.role not in ["Admin", "Organizer"]:
            raise PermissionDenied("Insufficient role for transition Registration -> Cancelled")
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

    @action(detail=True, methods=["patch"], url_path="transitions/ongoing-to-completed")
    def transition_ongoing_to_completed(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_queryset().get(pk=pk)
        if not hasattr(request.user, "role") or request.user.role not in ["Admin", "Organizer"]:
            raise PermissionDenied("Insufficient role for transition Ongoing -> Completed")
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Completed" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Completed not allowed"}, status=409)
        try:
            instance.status = "Completed"
            instance.complete()  # @after
            instance.calculate_prize_distribution()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/ongoing-to-cancelled")
    def transition_ongoing_to_cancelled(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_queryset().get(pk=pk)
        if not hasattr(request.user, "role") or request.user.role not in ["Admin"]:
            raise PermissionDenied("Insufficient role for transition Ongoing -> Cancelled")
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

    @action(detail=True, methods=["patch"], url_path="transitions/completed-to-draft")
    def transition_completed_to_draft(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        return Response({"error": "Transition Completed -> Draft is not allowed"}, status=409)

    @action(detail=True, methods=["patch"], url_path="transitions/cancelled-to-draft")
    def transition_cancelled_to_draft(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        return Response({"error": "Transition Cancelled -> Draft is not allowed"}, status=409)

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
    http_method_names = ['options', 'head', 'get', 'post', 'delete']
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
    http_method_names = ['options', 'head', 'get', 'post']
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status"]
    filterset_fields = ["status", "tournament", "player", "deck"]
    ordering_fields = "__all__"

    def get_object(self):
        obj = super().get_object()
        if obj.player_id != self.request.user.id:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("You do not own this resource.")
        return obj

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
    http_method_names = ['options', 'head', 'get', 'post']
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
    queryset = Match.objects.select_related("player1", "player2").all()
    serializer_class = MatchSerializer
    http_method_names = ['options', 'head', 'get', 'post', 'patch']
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

    @action(detail=True, methods=["post"], url_path="finalize")
    def finalize_result(self, request, pk=None):
        instance = self.get_object()
        result = instance.finalize_result()
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
        if not (instance.status == "Active"):
            from rest_framework.exceptions import ValidationError
            raise ValidationError({"detail": "Guard condition not met for concede"})
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

    @action(detail=True, methods=["patch"], url_path="transitions/pending-to-active")
    def transition_pending_to_active(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_queryset().get(pk=pk)
        if not hasattr(request.user, "role") or request.user.role not in ["Judge", "HeadJudge", "Admin"]:
            raise PermissionDenied("Insufficient role for transition Pending -> Active")
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Active" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Active not allowed"}, status=409)
        try:
            instance.status = "Active"
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/active-to-completed")
    def transition_active_to_completed(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_queryset().get(pk=pk)
        if not hasattr(request.user, "role") or request.user.role not in ["Judge", "HeadJudge", "Admin"]:
            raise PermissionDenied("Insufficient role for transition Active -> Completed")
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Completed" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Completed not allowed"}, status=409)
        try:
            instance.status = "Completed"
            instance.finalize_result()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/active-to-draw")
    def transition_active_to_draw(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_queryset().get(pk=pk)
        if not hasattr(request.user, "role") or request.user.role not in ["Judge", "HeadJudge", "Admin"]:
            raise PermissionDenied("Insufficient role for transition Active -> Draw")
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Draw" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Draw not allowed"}, status=409)
        try:
            instance.status = "Draw"
            instance.draw()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/pending-to-bye")
    def transition_pending_to_bye(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_queryset().get(pk=pk)
        if not hasattr(request.user, "role") or request.user.role not in ["Judge", "HeadJudge", "Admin"]:
            raise PermissionDenied("Insufficient role for transition Pending -> BYE")
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "BYE" not in allowed:
            return Response({"error": f"Transition {instance.status} -> BYE not allowed"}, status=409)
        try:
            instance.status = "BYE"
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/completed-to-active")
    def transition_completed_to_active(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        return Response({"error": "Transition Completed -> Active is not allowed"}, status=409)

    @action(detail=True, methods=["patch"], url_path="transitions/draw-to-active")
    def transition_draw_to_active(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        return Response({"error": "Transition Draw -> Active is not allowed"}, status=409)

    @action(detail=True, methods=["patch"], url_path="transitions/bye-to-active")
    def transition_bye_to_active(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        return Response({"error": "Transition BYE -> Active is not allowed"}, status=409)

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
    http_method_names = ['options', 'head', 'get', 'post']
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
    http_method_names = ['options', 'head', 'get']
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
