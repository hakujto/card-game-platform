from rest_framework import viewsets, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Player, PlayerSeasonStats, PlayerCollection, Friendship, Achievement, PlayerAchievement, CraftingRecipe, CraftingIngredient
from .serializers import PlayerSerializer, PlayerSeasonStatsSerializer, PlayerCollectionSerializer, FriendshipSerializer, AchievementSerializer, PlayerAchievementSerializer, CraftingRecipeSerializer, CraftingIngredientSerializer


class PlayerViewSet(viewsets.ModelViewSet):
    queryset = Player.objects.all()
    serializer_class = PlayerSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["display_name", "rank", "bio"]
    filterset_fields = ["rank", "preferred_format", "user", "season_stats"]


class PlayerSeasonStatsViewSet(viewsets.ModelViewSet):
    queryset = PlayerSeasonStats.objects.all()
    serializer_class = PlayerSeasonStatsSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["highest_rank"]
    filterset_fields = ["highest_rank", "player", "season"]


class PlayerCollectionViewSet(viewsets.ModelViewSet):
    queryset = PlayerCollection.objects.all()
    serializer_class = PlayerCollectionSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["condition", "acquired_via"]
    filterset_fields = ["condition", "acquired_via", "player", "card"]


class FriendshipViewSet(viewsets.ModelViewSet):
    queryset = Friendship.objects.all()
    serializer_class = FriendshipSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status"]
    filterset_fields = ["status", "requester", "receiver"]


class AchievementViewSet(viewsets.ModelViewSet):
    queryset = Achievement.objects.all()
    serializer_class = AchievementSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "description", "rarity"]
    filterset_fields = ["rarity"]


class PlayerAchievementViewSet(viewsets.ModelViewSet):
    queryset = PlayerAchievement.objects.all()
    serializer_class = PlayerAchievementSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["player", "achievement"]


class CraftingRecipeViewSet(viewsets.ModelViewSet):
    queryset = CraftingRecipe.objects.all()
    serializer_class = CraftingRecipeSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["result_card"]


class CraftingIngredientViewSet(viewsets.ModelViewSet):
    queryset = CraftingIngredient.objects.all()
    serializer_class = CraftingIngredientSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["recipe", "card"]
