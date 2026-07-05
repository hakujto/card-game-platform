from rest_framework import serializers
from .models import DraftSession, DraftParticipant, DraftPick, Article, ArticleTag, ArticleTagAssignment, ArticleComment, Stream
from players.models import Player


class DraftSessionSerializer(serializers.ModelSerializer):
    createdAt = serializers.DateTimeField(source="created_at")
    completedAt = serializers.DateTimeField(source="completed_at", required=False, allow_null=True)
    class Meta:
        model = DraftSession
        fields = [
            "id",
            "status",
            "draft_type",
            "pack_contents",
            "seats",
            "time_per_pick_seconds",
            "createdAt",
            "completedAt",
            "card_set",
        ]
        read_only_fields = ["id"]


class DraftParticipantSerializer(serializers.ModelSerializer):
    joinedAt = serializers.DateTimeField(source="joined_at")
    class Meta:
        model = DraftParticipant
        fields = [
            "id",
            "seat_number",
            "joinedAt",
            "session",
            "player",
        ]
        read_only_fields = ["id"]


class DraftPickSerializer(serializers.ModelSerializer):
    pickedAt = serializers.DateTimeField(source="picked_at")
    class Meta:
        model = DraftPick
        fields = [
            "id",
            "pick_number",
            "pack_number",
            "pickedAt",
            "participant",
            "card",
        ]
        read_only_fields = ["id"]


class ArticleSerializer(serializers.ModelSerializer):
    createdAt = serializers.DateTimeField(source="created_at")
    updatedAt = serializers.DateTimeField(source="updated_at")
    publishedAt = serializers.DateTimeField(source="published_at", required=False, allow_null=True)
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
            "language",
            "view_count",
            "likes_count",
            "total_views_alltime",
            "is_featured",
            "publishedAt",
            "createdAt",
            "updatedAt",
            "author",
            "featured_deck",
            "tags",
        ]
        read_only_fields = ["id"]

    def get_fields(self):
        fields = super().get_fields()
        request = self.context.get("request")
        if request and request.method == "PATCH":
            if "status" in fields: fields["status"].read_only = True
            if "view_count" in fields: fields["view_count"].read_only = True
            if "likes_count" in fields: fields["likes_count"].read_only = True
            if "created_at" in fields: fields["created_at"].read_only = True
        return fields


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


class ArticleCommentAuthorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Player
        fields = ["id", "display_name", "avatar_url"]


class ArticleCommentSerializer(serializers.ModelSerializer):
    author_data = ArticleCommentAuthorSerializer(source="author", read_only=True)
    author = serializers.PrimaryKeyRelatedField(queryset=Player.objects.all())
    createdAt = serializers.DateTimeField(source="created_at")
    class Meta:
        model = ArticleComment
        fields = [
            "id",
            "body",
            "is_hidden",
            "createdAt",
            "article",
            "author",
            "parent_comment",
            "author_data",
        ]
        read_only_fields = ["id"]


class StreamSerializer(serializers.ModelSerializer):
    scheduledStart = serializers.DateTimeField(source="scheduled_start")
    actualStart = serializers.DateTimeField(source="actual_start", required=False, allow_null=True)
    endedAt = serializers.DateTimeField(source="ended_at", required=False, allow_null=True)
    class Meta:
        model = Stream
        fields = [
            "id",
            "title",
            "stream_url",
            "status",
            "platform",
            "language",
            "is_official",
            "viewer_count_peak",
            "scheduledStart",
            "actualStart",
            "endedAt",
            "vod_url",
            "tournament",
            "streamer",
        ]
        read_only_fields = ["id"]
