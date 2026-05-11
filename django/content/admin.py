from django.contrib import admin
from .models import DraftSession, DraftParticipant, DraftPick, Article, ArticleTag, ArticleTagAssignment, ArticleComment, Stream


@admin.register(DraftSession)
class DraftSessionAdmin(admin.ModelAdmin):
    list_display = ["id", "status", "draft_type", "seats", "created_at"]
    search_fields = ["status", "draft_type"]
    list_filter = ["status", "draft_type", "card_set"]


@admin.register(DraftParticipant)
class DraftParticipantAdmin(admin.ModelAdmin):
    list_display = ["id", "seat_number", "joined_at", "session", "player"]
    list_filter = ["session", "player"]


@admin.register(DraftPick)
class DraftPickAdmin(admin.ModelAdmin):
    list_display = ["id", "pick_number", "pack_number", "picked_at", "participant"]
    list_filter = ["participant", "card"]


@admin.register(Article)
class ArticleAdmin(admin.ModelAdmin):
    list_display = ["id", "title", "slug", "body", "excerpt"]
    search_fields = ["title", "slug", "body"]
    list_filter = ["status", "article_type", "author", "featured_deck"]


@admin.register(ArticleTag)
class ArticleTagAdmin(admin.ModelAdmin):
    list_display = ["id", "name", "slug"]
    search_fields = ["name", "slug"]


@admin.register(ArticleTagAssignment)
class ArticleTagAssignmentAdmin(admin.ModelAdmin):
    list_display = ["id", "article", "tag"]
    list_filter = ["article", "tag"]


@admin.register(ArticleComment)
class ArticleCommentAdmin(admin.ModelAdmin):
    list_display = ["id", "body", "is_hidden", "created_at", "article"]
    search_fields = ["body"]
    list_filter = ["article", "author", "parent_comment"]


@admin.register(Stream)
class StreamAdmin(admin.ModelAdmin):
    list_display = ["id", "title", "stream_url", "platform", "status"]
    search_fields = ["title", "platform", "status"]
    list_filter = ["platform", "status", "tournament", "streamer"]
