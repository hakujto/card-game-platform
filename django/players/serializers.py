from rest_framework import serializers
from .models import Player, PlayerSeasonStats, PlayerCollection, Friendship, Achievement, PlayerAchievement, CraftingRecipe, CraftingIngredient


class PlayerSerializer(serializers.ModelSerializer):
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
            "created_at",
            "last_active_at",
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
    class Meta:
        model = PlayerCollection
        fields = [
            "id",
            "quantity",
            "foil",
            "condition",
            "acquired_at",
            "acquired_via",
            "player",
            "card",
        ]
        read_only_fields = ["id"]


class FriendshipSerializer(serializers.ModelSerializer):
    class Meta:
        model = Friendship
        fields = [
            "id",
            "status",
            "created_at",
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
    class Meta:
        model = PlayerAchievement
        fields = [
            "id",
            "earned_at",
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
