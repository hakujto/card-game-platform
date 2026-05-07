from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import DraftSessionViewSet, DraftParticipantViewSet, DraftPickViewSet, ArticleViewSet, ArticleTagViewSet, ArticleTagAssignmentViewSet, ArticleCommentViewSet, StreamViewSet

router = DefaultRouter()
router.register(r"draft_sessions", DraftSessionViewSet, basename="draft_session")
router.register(r"draft_participants", DraftParticipantViewSet, basename="draft_participant")
router.register(r"draft_picks", DraftPickViewSet, basename="draft_pick")
router.register(r"articles", ArticleViewSet, basename="article")
router.register(r"article_tags", ArticleTagViewSet, basename="article_tag")
router.register(r"article_tag_assignments", ArticleTagAssignmentViewSet, basename="article_tag_assignment")
router.register(r"article_comments", ArticleCommentViewSet, basename="article_comment")
router.register(r"streams", StreamViewSet, basename="stream")

urlpatterns = [
    path("", include(router.urls)),
]
