from rest_framework import serializers
from .models import Player, PlayerSeasonStats, PlayerCollection, Friendship, Achievement, PlayerAchievement, CraftingRecipe, CraftingIngredient


class PlayerSerializer(serializers.ModelSerializer):
    createdAt = serializers.DateTimeField(source="created_at")
    lastActiveAt = serializers.DateTimeField(source="last_active_at", required=False, allow_null=True)
    class Meta:
        model = Player
        fields = [
            "id",
            "display_name",
            "rank",
            "rating",
            "peak_rating",
            "bio",
            "country_code",
            "avatar_url",
            "preferred_format",
            "is_verified",
            "createdAt",
            "lastActiveAt",
            "user",
            "achievements",
            "friends",
        ]
        read_only_fields = ["id"]


class PlayerSeasonStatsSerializer(serializers.ModelSerializer):
    class Meta:
        model = PlayerSeasonStats
        fields = [
            "id",
            "wins",
            "losses",
            "draws",
            "tournament_wins",
            "highest_rank",
            "season_points",
            "player",
            "season",
        ]
        read_only_fields = ["id"]


class PlayerCollectionSerializer(serializers.ModelSerializer):
    acquiredAt = serializers.DateTimeField(source="acquired_at")
    class Meta:
        model = PlayerCollection
        fields = [
            "id",
            "quantity",
            "foil",
            "condition",
            "acquiredAt",
            "acquired_via",
            "player",
            "card",
        ]
        read_only_fields = ["id"]


class FriendshipSerializer(serializers.ModelSerializer):
    createdAt = serializers.DateTimeField(source="created_at")
    class Meta:
        model = Friendship
        fields = [
            "id",
            "status",
            "createdAt",
            "requester",
            "receiver",
        ]
        read_only_fields = ["id"]


class AchievementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Achievement
        fields = [
            "id",
            "name",
            "description",
            "icon_url",
            "points",
            "rarity",
            "is_hidden",
        ]
        read_only_fields = ["id"]


class PlayerAchievementSerializer(serializers.ModelSerializer):
    earnedAt = serializers.DateTimeField(source="earned_at")
    class Meta:
        model = PlayerAchievement
        fields = [
            "id",
            "earnedAt",
            "progress",
            "is_completed",
            "player",
            "achievement",
        ]
        read_only_fields = ["id"]


class CraftingRecipeSerializer(serializers.ModelSerializer):
    class Meta:
        model = CraftingRecipe
        fields = [
            "id",
            "dust_cost",
            "is_available",
            "result_card",
            "required_cards",
        ]
        read_only_fields = ["id"]


class CraftingIngredientSerializer(serializers.ModelSerializer):
    class Meta:
        model = CraftingIngredient
        fields = [
            "id",
            "quantity",
            "recipe",
            "card",
        ]
        read_only_fields = ["id"]
