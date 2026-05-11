from rest_framework import viewsets, filters
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


class DraftParticipantViewSet(viewsets.ModelViewSet):
    queryset = DraftParticipant.objects.select_related().all()
    serializer_class = DraftParticipantSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["session", "player"]
    ordering_fields = "__all__"


class DraftPickViewSet(viewsets.ModelViewSet):
    queryset = DraftPick.objects.select_related().all()
    serializer_class = DraftPickSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["participant", "card"]
    ordering_fields = "__all__"


class ArticleViewSet(viewsets.ModelViewSet):
    queryset = Article.objects.select_related().all()
    serializer_class = ArticleSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["title", "slug", "body"]
    filterset_fields = ["status", "article_type", "author", "featured_deck"]
    ordering_fields = "__all__"


class ArticleTagViewSet(viewsets.ModelViewSet):
    queryset = ArticleTag.objects.select_related().all()
    serializer_class = ArticleTagSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "slug"]
    ordering_fields = "__all__"


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


class StreamViewSet(viewsets.ModelViewSet):
    queryset = Stream.objects.select_related().all()
    serializer_class = StreamSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["title", "platform", "status"]
    filterset_fields = ["platform", "status", "tournament", "streamer"]
    ordering_fields = "__all__"
