from django.contrib import admin
from .models import Player, PlayerSeasonStats, PlayerCollection, Friendship, Achievement, PlayerAchievement, CraftingRecipe, CraftingIngredient


@admin.register(Player)
class PlayerAdmin(admin.ModelAdmin):
    list_display = ["id", "display_name", "rank", "rating", "peak_rating"]
    search_fields = ["display_name", "rank", "bio"]
    list_filter = ["rank", "preferred_format", "user", "season_stats"]


@admin.register(PlayerSeasonStats)
class PlayerSeasonStatsAdmin(admin.ModelAdmin):
    list_display = ["id", "wins", "losses", "draws", "tournament_wins"]
    search_fields = ["highest_rank"]
    list_filter = ["highest_rank", "player", "season"]


@admin.register(PlayerCollection)
class PlayerCollectionAdmin(admin.ModelAdmin):
    list_display = ["id", "quantity", "foil", "condition", "acquired_at"]
    search_fields = ["condition", "acquired_via"]
    list_filter = ["condition", "acquired_via", "player", "card"]


@admin.register(Friendship)
class FriendshipAdmin(admin.ModelAdmin):
    list_display = ["id", "status", "created_at", "requester", "receiver"]
    search_fields = ["status"]
    list_filter = ["status", "requester", "receiver"]


@admin.register(Achievement)
class AchievementAdmin(admin.ModelAdmin):
    list_display = ["id", "name", "description", "icon_url", "points"]
    search_fields = ["name", "description", "rarity"]
    list_filter = ["rarity"]


@admin.register(PlayerAchievement)
class PlayerAchievementAdmin(admin.ModelAdmin):
    list_display = ["id", "earned_at", "progress", "is_completed", "player"]
    list_filter = ["player", "achievement"]


@admin.register(CraftingRecipe)
class CraftingRecipeAdmin(admin.ModelAdmin):
    list_display = ["id", "dust_cost", "is_available", "result_card"]
    list_filter = ["result_card"]


@admin.register(CraftingIngredient)
class CraftingIngredientAdmin(admin.ModelAdmin):
    list_display = ["id", "quantity", "recipe", "card"]
    list_filter = ["recipe", "card"]
