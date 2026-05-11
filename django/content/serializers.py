from rest_framework import serializers
from .models import DraftSession, DraftParticipant, DraftPick, Article, ArticleTag, ArticleTagAssignment, ArticleComment, Stream


class DraftSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = DraftSession
        fields = [
            "id",
            "status",
            "draft_type",
            "seats",
            "created_at",
            "completed_at",
            "card_set",
        ]
        read_only_fields = ["id"]


class DraftParticipantSerializer(serializers.ModelSerializer):
    class Meta:
        model = DraftParticipant
        fields = [
            "id",
            "seat_number",
            "joined_at",
            "session",
            "player",
        ]
        read_only_fields = ["id"]


class DraftPickSerializer(serializers.ModelSerializer):
    class Meta:
        model = DraftPick
        fields = [
            "id",
            "pick_number",
            "pack_number",
            "picked_at",
            "participant",
            "card",
        ]
        read_only_fields = ["id"]


class ArticleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Article
        fields = [
            "id",
            "title",
            "slug",
            "body",
            "excerpt",
            "cover_image_url",
            "status",
            "article_type",
            "view_count",
            "published_at",
            "created_at",
            "updated_at",
            "author",
            "featured_deck",
            "tags",
        ]
        read_only_fields = ["id"]


class ArticleTagSerializer(serializers.ModelSerializer):
    class Meta:
        model = ArticleTag
        fields = [
            "id",
            "name",
            "slug",
        ]
        read_only_fields = ["id"]


class ArticleTagAssignmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = ArticleTagAssignment
        fields = [
            "id",
            "article",
            "tag",
        ]
        read_only_fields = ["id"]


class ArticleCommentSerializer(serializers.ModelSerializer):
    class Meta:
        model = ArticleComment
        fields = [
            "id",
            "body",
            "is_hidden",
            "created_at",
            "article",
            "author",
            "parent_comment",
        ]
        read_only_fields = ["id"]


class StreamSerializer(serializers.ModelSerializer):
    class Meta:
        model = Stream
        fields = [
            "id",
            "title",
            "stream_url",
            "platform",
            "status",
            "viewer_count_peak",
            "scheduled_start",
            "actual_start",
            "ended_at",
            "vod_url",
            "tournament",
            "streamer",
        ]
        read_only_fields = ["id"]
