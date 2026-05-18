from django.test import TestCase
from ..models import Player, PlayerSeasonStats, PlayerCollection, Friendship, Achievement, PlayerAchievement, CraftingRecipe, CraftingIngredient


class PlayerModelTest(TestCase):
    def setUp(self):
        self.obj = Player.objects.create(display_name="test", peak_rating=1000, created_at="2024-01-01T00:00:00Z")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class PlayerSeasonStatsModelTest(TestCase):
    def setUp(self):
        from tournaments.models import Season as _SeasonCls
        _dep_season = _SeasonCls.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-02")
        self.obj = PlayerSeasonStats.objects.create(season=_dep_season, wins=0, losses=0, tournament_wins=0, season_points=0)

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class PlayerCollectionModelTest(TestCase):
    def setUp(self):
        _dep_player = Player.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=1)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        self.obj = PlayerCollection.objects.create(player=_dep_player, card=_dep_card, quantity=1, acquired_at="2024-01-01T00:00:00Z")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class FriendshipModelTest(TestCase):
    def setUp(self):
        _dep_player = Player.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        self.obj = Friendship.objects.create(requester=_dep_player, receiver=_dep_player, created_at="2024-01-01T00:00:00Z")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class AchievementModelTest(TestCase):
    def setUp(self):
        self.obj = Achievement.objects.create(name="test", description="test", points=1)

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class PlayerAchievementModelTest(TestCase):
    def setUp(self):
        _dep_player = Player.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_achievement = Achievement.objects.create(name="test", description="test")
        self.obj = PlayerAchievement.objects.create(player=_dep_player, achievement=_dep_achievement, earned_at="2024-01-01T00:00:00Z", progress=0)

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class CraftingRecipeModelTest(TestCase):
    def setUp(self):
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=1)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        self.obj = CraftingRecipe.objects.create(result_card=_dep_card, dust_cost=1)

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class CraftingIngredientModelTest(TestCase):
    def setUp(self):
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=1)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        _dep_crafting_recipe = CraftingRecipe.objects.create(dust_cost=1, result_card=_dep_card)
        self.obj = CraftingIngredient.objects.create(recipe=_dep_crafting_recipe, card=_dep_card)

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)
