from rest_framework import viewsets, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Player, PlayerSeasonStats, PlayerCollection, Friendship, Achievement, PlayerAchievement, CraftingRecipe, CraftingIngredient
from .serializers import PlayerSerializer, PlayerSeasonStatsSerializer, PlayerCollectionSerializer, FriendshipSerializer, AchievementSerializer, PlayerAchievementSerializer, CraftingRecipeSerializer, CraftingIngredientSerializer


class PlayerViewSet(viewsets.ModelViewSet):
    queryset = Player.objects.select_related().all()
    serializer_class = PlayerSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["display_name", "rank", "bio"]
    filterset_fields = ["rank", "preferred_format", "user"]
    ordering_fields = "__all__"


class PlayerSeasonStatsViewSet(viewsets.ModelViewSet):
    queryset = PlayerSeasonStats.objects.select_related().all()
    serializer_class = PlayerSeasonStatsSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["highest_rank"]
    filterset_fields = ["highest_rank", "player", "season"]
    ordering_fields = "__all__"


class PlayerCollectionViewSet(viewsets.ModelViewSet):
    queryset = PlayerCollection.objects.select_related().all()
    serializer_class = PlayerCollectionSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["condition", "acquired_via"]
    filterset_fields = ["condition", "acquired_via", "player", "card"]
    ordering_fields = "__all__"


class FriendshipViewSet(viewsets.ModelViewSet):
    queryset = Friendship.objects.select_related().all()
    serializer_class = FriendshipSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status"]
    filterset_fields = ["status", "requester", "receiver"]
    ordering_fields = "__all__"


class AchievementViewSet(viewsets.ModelViewSet):
    queryset = Achievement.objects.select_related().all()
    serializer_class = AchievementSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "description", "rarity"]
    filterset_fields = ["rarity"]
    ordering_fields = "__all__"


class PlayerAchievementViewSet(viewsets.ModelViewSet):
    queryset = PlayerAchievement.objects.select_related().all()
    serializer_class = PlayerAchievementSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["player", "achievement"]
    ordering_fields = "__all__"


class CraftingRecipeViewSet(viewsets.ModelViewSet):
    queryset = CraftingRecipe.objects.select_related().all()
    serializer_class = CraftingRecipeSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["result_card"]
    ordering_fields = "__all__"


class CraftingIngredientViewSet(viewsets.ModelViewSet):
    queryset = CraftingIngredient.objects.select_related().all()
    serializer_class = CraftingIngredientSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["recipe", "card"]
    ordering_fields = "__all__"
