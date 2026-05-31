from rest_framework import viewsets, filters
from rest_framework.decorators import action
from django_filters.rest_framework import DjangoFilterBackend
from .models import DraftSession, DraftParticipant, DraftPick, Article, ArticleTag, ArticleTagAssignment, ArticleComment, Stream
from .serializers import DraftSessionSerializer, DraftParticipantSerializer, DraftPickSerializer, ArticleSerializer, ArticleTagSerializer, ArticleTagAssignmentSerializer, ArticleCommentSerializer, StreamSerializer


class DraftSessionViewSet(viewsets.ModelViewSet):
    queryset = DraftSession.objects.select_related().all()
    serializer_class = DraftSessionSerializer
    http_method_names = ['options', 'head', 'get', 'post', 'patch']
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status", "draft_type"]
    filterset_fields = ["status", "draft_type", "card_set"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="start")
    def start(self, request, pk=None):
        instance = self.get_object()
        result = instance.start()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="abandon")
    def abandon(self, request, pk=None):
        instance = self.get_object()
        result = instance.abandon()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="complete")
    def complete(self, request, pk=None):
        instance = self.get_object()
        result = instance.complete()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="full")
    def is_full(self, request, pk=None):
        instance = self.get_object()
        result = instance.is_full()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["patch"], url_path="transitions/waitingforplayers-to-drafting")
    def transition_waitingforplayers_to_drafting(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Drafting" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Drafting not allowed"}, status=409)
        try:
            instance.status = "Drafting"
            instance.start()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/drafting-to-completed")
    def transition_drafting_to_completed(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Completed" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Completed not allowed"}, status=409)
        try:
            instance.status = "Completed"
            instance.complete()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/drafting-to-abandoned")
    def transition_drafting_to_abandoned(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Abandoned" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Abandoned not allowed"}, status=409)
        try:
            instance.status = "Abandoned"
            instance.abandon()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/waitingforplayers-to-abandoned")
    def transition_waitingforplayers_to_abandoned(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Abandoned" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Abandoned not allowed"}, status=409)
        try:
            instance.status = "Abandoned"
            instance.abandon()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/completed-to-drafting")
    def transition_completed_to_drafting(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        return Response({"error": "Transition Completed -> Drafting is not allowed"}, status=409)

    @action(detail=True, methods=["patch"], url_path="transitions/abandoned-to-drafting")
    def transition_abandoned_to_drafting(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        return Response({"error": "Transition Abandoned -> Drafting is not allowed"}, status=409)

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


class DraftParticipantViewSet(viewsets.ModelViewSet):
    queryset = DraftParticipant.objects.select_related().all()
    serializer_class = DraftParticipantSerializer
    http_method_names = ['options', 'head', 'get', 'post']
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["session", "player"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="pick")
    def pick_card(self, request, pk=None):
        instance = self.get_object()
        card_id = request.data.get("card_id")
        pack_number = request.data.get("pack_number")
        result = instance.pick_card(card_id, pack_number)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="card-count")
    def drafted_card_count(self, request, pk=None):
        instance = self.get_object()
        result = instance.drafted_card_count()
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


class DraftPickViewSet(viewsets.ModelViewSet):
    queryset = DraftPick.objects.select_related().all()
    serializer_class = DraftPickSerializer
    http_method_names = ['options', 'head', 'get']
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["participant", "card"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["get"], url_path="first-pick")
    def is_first_pick(self, request, pk=None):
        instance = self.get_object()
        result = instance.is_first_pick()
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


class ArticleViewSet(viewsets.ModelViewSet):
    queryset = Article.objects.select_related().all()
    serializer_class = ArticleSerializer
    http_method_names = ['options', 'head', 'get', 'post', 'put', 'patch']
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["title", "excerpt"]
    filterset_fields = ["status", "article_type", "language", "author", "featured_deck"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="publish")
    def publish(self, request, pk=None):
        instance = self.get_object()
        result = instance.publish()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="archive")
    def archive(self, request, pk=None):
        instance = self.get_object()
        result = instance.archive()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="view")
    def increment_view(self, request, pk=None):
        instance = self.get_object()
        result = instance.increment_view()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="like")
    def like(self, request, pk=None):
        instance = self.get_object()
        result = instance.like()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["delete"], url_path="like")
    def unlike(self, request, pk=None):
        instance = self.get_object()
        result = instance.unlike()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="reading-time")
    def reading_time_minutes(self, request, pk=None):
        instance = self.get_object()
        result = instance.reading_time_minutes()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["patch"], url_path="transitions/draft-to-published")
    def transition_draft_to_published(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Published" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Published not allowed"}, status=409)
        try:
            if instance.title is None:
                raise DjangoValidationError({"title": "title is required for Draft -> Published"})
            if instance.body is None:
                raise DjangoValidationError({"body": "body is required for Draft -> Published"})
            instance.status = "Published"
            instance.publish()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/published-to-archived")
    def transition_published_to_archived(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Archived" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Archived not allowed"}, status=409)
        try:
            instance.status = "Archived"
            instance.archive()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/archived-to-draft")
    def transition_archived_to_draft(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Draft" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Draft not allowed"}, status=409)
        try:
            instance.status = "Draft"
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/published-to-draft")
    def transition_published_to_draft(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        return Response({"error": "Transition Published -> Draft is not allowed"}, status=409)

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


class ArticleTagViewSet(viewsets.ModelViewSet):
    queryset = ArticleTag.objects.select_related().all()
    serializer_class = ArticleTagSerializer
    http_method_names = ['options', 'head', 'get', 'post', 'patch', 'delete']
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["patch"], url_path="rename")
    def rename(self, request, pk=None):
        instance = self.get_object()
        new_name = request.data.get("new_name")
        result = instance.rename(new_name)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="article-count")
    def article_count(self, request, pk=None):
        instance = self.get_object()
        result = instance.article_count()
        from rest_framework.response import Response
        return Response({"result": result})


class ArticleTagAssignmentViewSet(viewsets.ModelViewSet):
    queryset = ArticleTagAssignment.objects.select_related().all()
    serializer_class = ArticleTagAssignmentSerializer
    http_method_names = ['options', 'head', 'get', 'post', 'delete']
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["article", "tag"]
    ordering_fields = "__all__"


class ArticleCommentViewSet(viewsets.ModelViewSet):
    queryset = ArticleComment.objects.select_related().all()
    serializer_class = ArticleCommentSerializer
    http_method_names = ['options', 'head', 'get', 'post', 'delete']
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["body"]
    filterset_fields = ["article", "author", "parent_comment"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="hide")
    def hide(self, request, pk=None):
        instance = self.get_object()
        result = instance.hide()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="unhide")
    def unhide(self, request, pk=None):
        instance = self.get_object()
        result = instance.unhide()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="is-reply")
    def is_reply(self, request, pk=None):
        instance = self.get_object()
        result = instance.is_reply()
        from rest_framework.response import Response
        return Response({"result": result})


class StreamViewSet(viewsets.ModelViewSet):
    queryset = Stream.objects.select_related().all()
    serializer_class = StreamSerializer
    http_method_names = ['options', 'head', 'get', 'post', 'put', 'patch']
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["title"]
    filterset_fields = ["status", "platform", "language", "tournament", "streamer"]
    ordering_fields = "__all__"

    @action(detail=True, methods=["post"], url_path="live")
    def go_live(self, request, pk=None):
        instance = self.get_object()
        result = instance.go_live()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["post"], url_path="end")
    def end(self, request, pk=None):
        instance = self.get_object()
        result = instance.end()
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["patch"], url_path="viewers")
    def update_viewer_peak(self, request, pk=None):
        instance = self.get_object()
        count = request.data.get("count")
        result = instance.update_viewer_peak(count)
        from rest_framework.response import Response
        return Response(status=204)

    @action(detail=True, methods=["get"], url_path="duration")
    def duration_minutes(self, request, pk=None):
        instance = self.get_object()
        result = instance.duration_minutes()
        from rest_framework.response import Response
        return Response({"result": result})

    @action(detail=True, methods=["patch"], url_path="transitions/scheduled-to-live")
    def transition_scheduled_to_live(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Live" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Live not allowed"}, status=409)
        try:
            if instance.stream_url is None:
                raise DjangoValidationError({"stream_url": "stream_url is required for Scheduled -> Live"})
            instance.status = "Live"
            instance.go_live()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/live-to-ended")
    def transition_live_to_ended(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        allowed = instance.ALLOWED_TRANSITIONS.get(instance.status, [])
        if "Ended" not in allowed:
            return Response({"error": f"Transition {instance.status} -> Ended not allowed"}, status=409)
        try:
            instance.status = "Ended"
            instance.end()  # @after
            instance.save()
            serializer = self.get_serializer(instance)
            return Response(serializer.data)
        except DjangoValidationError as e:
            raise ValidationError(e.message_dict if hasattr(e, "message_dict") else str(e))

    @action(detail=True, methods=["patch"], url_path="transitions/ended-to-live")
    def transition_ended_to_live(self, request, pk=None):
        from rest_framework.response import Response
        from rest_framework.exceptions import ValidationError, PermissionDenied
        from django.core.exceptions import ValidationError as DjangoValidationError
        instance = self.get_object()
        return Response({"error": "Transition Ended -> Live is not allowed"}, status=409)

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
