from django.test import TestCase
from ..models import Card, CardSet, CardRuling, CardAbility, Deck, DeckCard, DeckSideboardCard, DeckTag, DeckTagAssignment


class CardModelTest(TestCase):
    def setUp(self):
        _dep_card_set = CardSet.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        self.obj = Card.objects.create(set=_dep_card_set, name="test", mana_colors="White", attack=0, defense=0, loyalty=0, description="test", legal_formats="Standard", is_banned=False, is_restricted=False, power_level=1)

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class CardSetModelTest(TestCase):
    def setUp(self):
        self.obj = CardSet.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class CardRulingModelTest(TestCase):
    def setUp(self):
        _dep_card_set = CardSet.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        _dep_card = Card.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        self.obj = CardRuling.objects.create(card=_dep_card, ruling_text="test", published_at="2024-01-01", source="test")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class CardAbilityModelTest(TestCase):
    def setUp(self):
        _dep_card_set = CardSet.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        _dep_card = Card.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        self.obj = CardAbility.objects.create(card=_dep_card, keyword="test", ability_text="test")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class DeckModelTest(TestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        self.obj = Deck.objects.create(player=_dep_player, name="test", created_at="2024-01-01T00:00:00Z", updated_at="2024-01-01T00:00:00Z")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class DeckCardModelTest(TestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_deck = Deck.objects.create(name="test", created_at="2024-01-01T00:00:00Z", updated_at="2024-01-01T00:00:00Z", player=_dep_player)
        _dep_card_set = CardSet.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        _dep_card = Card.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        self.obj = DeckCard.objects.create(deck=_dep_deck, card=_dep_card, quantity=1)

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class DeckSideboardCardModelTest(TestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_deck = Deck.objects.create(name="test", created_at="2024-01-01T00:00:00Z", updated_at="2024-01-01T00:00:00Z", player=_dep_player)
        _dep_card_set = CardSet.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        _dep_card = Card.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        self.obj = DeckSideboardCard.objects.create(deck=_dep_deck, card=_dep_card)

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class DeckTagModelTest(TestCase):
    def setUp(self):
        self.obj = DeckTag.objects.create(name="test")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class DeckTagAssignmentModelTest(TestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_deck = Deck.objects.create(name="test", created_at="2024-01-01T00:00:00Z", updated_at="2024-01-01T00:00:00Z", player=_dep_player)
        _dep_deck_tag = DeckTag.objects.create(name="test")
        self.obj = DeckTagAssignment.objects.create(deck=_dep_deck, tag=_dep_deck_tag)

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)
