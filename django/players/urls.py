from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import PlayerViewSet, PlayerSeasonStatsViewSet, PlayerCollectionViewSet, FriendshipViewSet, AchievementViewSet, PlayerAchievementViewSet, CraftingRecipeViewSet, CraftingIngredientViewSet

router = DefaultRouter()
router.register(r"players", PlayerViewSet, basename="player")
router.register(r"player_season_statses", PlayerSeasonStatsViewSet, basename="player_season_stats")
router.register(r"player_collections", PlayerCollectionViewSet, basename="player_collection")
router.register(r"friendships", FriendshipViewSet, basename="friendship")
router.register(r"achievements", AchievementViewSet, basename="achievement")
router.register(r"player_achievements", PlayerAchievementViewSet, basename="player_achievement")
router.register(r"crafting_recipes", CraftingRecipeViewSet, basename="crafting_recipe")
router.register(r"crafting_ingredients", CraftingIngredientViewSet, basename="crafting_ingredient")

urlpatterns = [
    path("", include(router.urls)),
]
