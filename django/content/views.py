from rest_framework import viewsets, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import DraftSession, DraftParticipant, DraftPick, Article, ArticleTag, ArticleTagAssignment, ArticleComment, Stream
from .serializers import DraftSessionSerializer, DraftParticipantSerializer, DraftPickSerializer, ArticleSerializer, ArticleTagSerializer, ArticleTagAssignmentSerializer, ArticleCommentSerializer, StreamSerializer


class DraftSessionViewSet(viewsets.ModelViewSet):
    queryset = DraftSession.objects.all()
    serializer_class = DraftSessionSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status", "draft_type"]
    filterset_fields = ["status", "draft_type", "card_set", "participants"]


class DraftParticipantViewSet(viewsets.ModelViewSet):
    queryset = DraftParticipant.objects.all()
    serializer_class = DraftParticipantSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["session", "player", "drafted_cards"]


class DraftPickViewSet(viewsets.ModelViewSet):
    queryset = DraftPick.objects.all()
    serializer_class = DraftPickSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["participant", "card"]


class ArticleViewSet(viewsets.ModelViewSet):
    queryset = Article.objects.all()
    serializer_class = ArticleSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["title", "slug", "body"]
    filterset_fields = ["status", "article_type", "author", "featured_deck", "comments"]


class ArticleTagViewSet(viewsets.ModelViewSet):
    queryset = ArticleTag.objects.all()
    serializer_class = ArticleTagSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "slug"]


class ArticleTagAssignmentViewSet(viewsets.ModelViewSet):
    queryset = ArticleTagAssignment.objects.all()
    serializer_class = ArticleTagAssignmentSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["article", "tag"]


class ArticleCommentViewSet(viewsets.ModelViewSet):
    queryset = ArticleComment.objects.all()
    serializer_class = ArticleCommentSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["body"]
    filterset_fields = ["article", "author", "parent_comment"]


class StreamViewSet(viewsets.ModelViewSet):
    queryset = Stream.objects.all()
    serializer_class = StreamSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["title", "platform", "status"]
    filterset_fields = ["platform", "status", "tournament", "streamer"]
