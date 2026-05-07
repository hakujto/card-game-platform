from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from .models import Player, PlayerSeasonStats, PlayerCollection, Friendship, Achievement, PlayerAchievement, CraftingRecipe, CraftingIngredient


class PlayerAPITest(APITestCase):
    def setUp(self):
        self.player_season_stats = PlayerSeasonStats.objects.create()
        # TODO: create related User (cross-app dependency)
        self.obj = Player.objects.create(
            season_stats=self.player_season_stats,
            display_name="test",
            bio="test",
            country_code="test",
            avatar_url="https://example.com",
            preferred_format="test",
            created_at="2024-01-01T00:00:00Z",
            last_active_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("player-list")
        self.detail_url = reverse("player-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"display_name": "test", "rank": "test", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"display_name": "test"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class PlayerSeasonStatsAPITest(APITestCase):
    def setUp(self):
        self.player = Player.objects.create()
        # TODO: create related Season (cross-app dependency)
        self.obj = PlayerSeasonStats.objects.create(
            player=self.player,
            highest_rank="test",
        )
        self.list_url = reverse("player_season_stats-list")
        self.detail_url = reverse("player_season_stats-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"wins": 0, "losses": 0, "draws": 0, "tournament_wins": 0, "season_points": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"wins": 0}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class PlayerCollectionAPITest(APITestCase):
    def setUp(self):
        self.player = Player.objects.create()
        # TODO: create related Card (cross-app dependency)
        self.obj = PlayerCollection.objects.create(
            player=self.player,
            acquired_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("player_collection-list")
        self.detail_url = reverse("player_collection-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"quantity": 0, "foil": False, "condition": "test", "acquired_at": "2024-01-01T00:00:00Z", "acquired_via": "test"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"quantity": 0}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class FriendshipAPITest(APITestCase):
    def setUp(self):
        self.player = Player.objects.create()
        self.player = Player.objects.create()
        self.obj = Friendship.objects.create(
            requester=self.player,
            receiver=self.player,
            created_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("friendship-list")
        self.detail_url = reverse("friendship-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"status": "test", "created_at": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"status": "test"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class AchievementAPITest(APITestCase):
    def setUp(self):
        self.obj = Achievement.objects.create(
            name="test",
            description="test",
            icon_url="https://example.com",
        )
        self.list_url = reverse("achievement-list")
        self.detail_url = reverse("achievement-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"name": "test", "description": "test", "points": 0, "rarity": "test", "is_hidden": False}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"name": "test"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class PlayerAchievementAPITest(APITestCase):
    def setUp(self):
        self.player = Player.objects.create()
        self.achievement = Achievement.objects.create()
        self.obj = PlayerAchievement.objects.create(
            player=self.player,
            achievement=self.achievement,
            earned_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("player_achievement-list")
        self.detail_url = reverse("player_achievement-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"earned_at": "2024-01-01T00:00:00Z", "progress": 0, "is_completed": False}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"earned_at": "2024-01-01T00:00:00Z"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class CraftingRecipeAPITest(APITestCase):
    def setUp(self):
        # TODO: create related Card (cross-app dependency)
        self.obj = CraftingRecipe.objects.create(
            dust_cost=0,
        )
        self.list_url = reverse("crafting_recipe-list")
        self.detail_url = reverse("crafting_recipe-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"dust_cost": 0, "is_available": False}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"dust_cost": 0}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class CraftingIngredientAPITest(APITestCase):
    def setUp(self):
        self.crafting_recipe = CraftingRecipe.objects.create()
        # TODO: create related Card (cross-app dependency)
        self.obj = CraftingIngredient.objects.create(
            recipe=self.crafting_recipe,
        )
        self.list_url = reverse("crafting_ingredient-list")
        self.detail_url = reverse("crafting_ingredient-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"quantity": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"quantity": 0}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)
