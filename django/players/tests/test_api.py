from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from ..models import Player, PlayerSeasonStats, PlayerCollection, Friendship, Achievement, PlayerAchievement, CraftingRecipe, CraftingIngredient


class PlayerAPITest(APITestCase):
    def setUp(self):
        self.obj = Player.objects.create(display_name="test", peak_rating=1000, created_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("player-list")
        self.detail_url = reverse("player-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "display_name": "test",
            "peak_rating": 1000,
            "created_at": "2024-01-01T00:00:00Z"
        }
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

    def test_create_fails_when_rating_range_violated(self):
        # Simple rule violated → 400
        data = {"display_name": "test", "created_at": "2024-01-01T00:00:00Z", "rating": 10000}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_display_name_not_empty_violated(self):
        # Simple rule violated → 400
        data = {"display_name": None, "created_at": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class PlayerSeasonStatsAPITest(APITestCase):
    def setUp(self):
        from tournaments.models import Season as _SeasonCls
        _dep_season = _SeasonCls.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-02")
        self.season = _dep_season
        self.obj = PlayerSeasonStats.objects.create(season=_dep_season)
        self.list_url = reverse("player_season_stats-list")
        self.detail_url = reverse("player_season_stats-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "season": self.season.pk
        }
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
        _dep_player = Player.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        self.player = _dep_player
        self.cardset = _dep_card_set
        self.card = _dep_card
        self.obj = PlayerCollection.objects.create(player=_dep_player, card=_dep_card, acquired_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("player_collection-list")
        self.detail_url = reverse("player_collection-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "acquired_at": "2024-01-01T00:00:00Z",
            "player": self.player.pk,
            "card": self.card.pk
        }
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
        _dep_player = Player.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        self.player = _dep_player
        self.obj = Friendship.objects.create(requester=_dep_player, receiver=_dep_player, created_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("friendship-list")
        self.detail_url = reverse("friendship-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "created_at": "2024-01-01T00:00:00Z",
            "requester": self.player.pk,
            "receiver": self.player.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"created_at": "2024-01-01T00:00:00Z"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class AchievementAPITest(APITestCase):
    def setUp(self):
        self.obj = Achievement.objects.create(name="test", description="test")
        self.list_url = reverse("achievement-list")
        self.detail_url = reverse("achievement-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "name": "test",
            "description": "test"
        }
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
        _dep_player = Player.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_achievement = Achievement.objects.create(name="test", description="test")
        self.player = _dep_player
        self.achievement = _dep_achievement
        self.obj = PlayerAchievement.objects.create(player=_dep_player, achievement=_dep_achievement, earned_at="2024-01-01T00:00:00Z", progress=1)
        self.list_url = reverse("player_achievement-list")
        self.detail_url = reverse("player_achievement-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "earned_at": "2024-01-01T00:00:00Z",
            "progress": 1,
            "player": self.player.pk,
            "achievement": self.achievement.pk
        }
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

    def test_create_fails_when_completed_requires_progress_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"earned_at": "2024-01-01T00:00:00Z", "is_completed": True, "progress": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class CraftingRecipeAPITest(APITestCase):
    def setUp(self):
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        self.cardset = _dep_card_set
        self.card = _dep_card
        self.obj = CraftingRecipe.objects.create(result_card=_dep_card, dust_cost=1)
        self.list_url = reverse("crafting_recipe-list")
        self.detail_url = reverse("crafting_recipe-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "dust_cost": 1,
            "result_card": self.card.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"dust_cost": 1}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

    def test_create_fails_when_dust_cost_positive_violated(self):
        # Simple rule violated → 400
        data = {"dust_cost": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class CraftingIngredientAPITest(APITestCase):
    def setUp(self):
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        _dep_crafting_recipe = CraftingRecipe.objects.create(dust_cost=1, result_card=_dep_card)
        self.cardset = _dep_card_set
        self.card = _dep_card
        self.craftingrecipe = _dep_crafting_recipe
        self.obj = CraftingIngredient.objects.create(recipe=_dep_crafting_recipe, card=_dep_card)
        self.list_url = reverse("crafting_ingredient-list")
        self.detail_url = reverse("crafting_ingredient-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "recipe": self.craftingrecipe.pk,
            "card": self.card.pk
        }
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
