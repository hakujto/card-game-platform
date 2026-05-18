from rest_framework import viewsets, filters
from rest_framework.decorators import action
from django_filters.rest_framework import DjangoFilterBackend
from .models import DraftSession, DraftParticipant, DraftPick, Article, ArticleTag, ArticleTagAssignment, ArticleComment, Stream
from .serializers import DraftSessionSerializer, DraftParticipantSerializer, DraftPickSerializer, ArticleSerializer, ArticleTagSerializer, ArticleTagAssignmentSerializer, ArticleCommentSerializer, StreamSerializer


class DraftSessionViewSet(viewsets.ModelViewSet):
    queryset = DraftSession.objects.select_related().all()
    serializer_class = DraftSessionSerializer
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
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["title", "slug", "body"]
    filterset_fields = ["status", "article_type", "author", "featured_deck"]
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

    @action(detail=True, methods=["get"], url_path="reading-time")
    def reading_time_minutes(self, request, pk=None):
        instance = self.get_object()
        result = instance.reading_time_minutes()
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


class ArticleTagViewSet(viewsets.ModelViewSet):
    queryset = ArticleTag.objects.select_related().all()
    serializer_class = ArticleTagSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "slug"]
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
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["article", "tag"]
    ordering_fields = "__all__"


class ArticleCommentViewSet(viewsets.ModelViewSet):
    queryset = ArticleComment.objects.select_related().all()
    serializer_class = ArticleCommentSerializer
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
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["title", "platform", "status"]
    filterset_fields = ["platform", "status", "tournament", "streamer"]
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
