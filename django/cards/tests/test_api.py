from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from ..models import Card, CardSet, CardRuling, CardAbility, Deck, DeckCard, DeckSideboardCard, DeckTag, DeckTagAssignment


class CardAPITest(APITestCase):
    def setUp(self):
        _dep_card_set = CardSet.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=1)
        self.cardset = _dep_card_set
        self.obj = Card.objects.create(set=_dep_card_set, name="test", mana_colors="White", attack=0, defense=0, loyalty=None, description="test", legal_formats="Standard", is_banned=False, is_restricted=False, power_level=1)
        self.list_url = reverse("card-list")
        self.detail_url = reverse("card-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "name": "test",
            "mana_colors": "White",
            "attack": 0,
            "defense": 0,
            "loyalty": None,
            "description": "test",
            "legal_formats": "Standard",
            "is_banned": False,
            "is_restricted": False,
            "power_level": 1,
            "set": self.cardset.pk
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

    def test_create_fails_when_creature_requires_stats_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"name": "test", "mana_colors": "White", "description": "test", "legal_formats": "Standard", "set": self.cardset.pk, "card_type": "Creature", "attack": None}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_planeswalker_requires_loyalty_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"name": "test", "mana_colors": "White", "description": "test", "legal_formats": "Standard", "set": self.cardset.pk, "card_type": "Planeswalker", "loyalty": None}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_spell_or_artifact_no_loyalty_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"name": "test", "mana_colors": "White", "description": "test", "legal_formats": "Standard", "set": self.cardset.pk, "loyalty": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_mana_cost_range_violated(self):
        # Simple rule violated → 400
        data = {"name": "test", "mana_colors": "White", "description": "test", "legal_formats": "message", "set": self.cardset.pk, "card_type": "Planeswalker", "attack": 0, "defense": 0, "loyalty": None, "is_banned": True, "mana_cost": 21}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_power_level_range_violated(self):
        # Simple rule violated → 400
        data = {"name": "test", "mana_colors": "White", "description": "test", "legal_formats": "message", "set": self.cardset.pk, "card_type": "Planeswalker", "attack": 0, "defense": 0, "loyalty": None, "is_banned": True, "power_level": 11}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_not_banned_and_restricted_violated(self):
        # Simple rule violated → 400
        data = {"name": "test", "mana_colors": "White", "description": "test", "legal_formats": "message", "set": self.cardset.pk, "card_type": "Planeswalker", "attack": 0, "defense": 0, "loyalty": None, "is_banned": True, "is_restricted": True}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_banned_card_not_in_legal_formats_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"name": "test", "mana_colors": "White", "description": "test", "legal_formats": "Standard", "set": self.cardset.pk, "is_banned": True}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class CardSetAPITest(APITestCase):
    def setUp(self):
        self.obj = CardSet.objects.create(name="test", code="test", release_date="2024-01-01", rotation_date=None, total_cards=1)
        self.list_url = reverse("card_set-list")
        self.detail_url = reverse("card_set-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "name": "test",
            "code": "test",
            "release_date": "2024-01-01",
            "rotation_date": None,
            "total_cards": 1
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

    def test_create_fails_when_total_cards_positive_violated(self):
        # Simple rule violated → 400
        data = {"name": "test", "code": "test", "release_date": "2024-01-01", "total_cards": 0, "rotation_date": "2024-01-01", "is_rotated": True}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_rotation_date_after_release_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"name": "test", "code": "test", "release_date": "2024-01-01", "total_cards": 0, "rotation_date": "2024-01-01"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_rotated_set_has_rotation_date_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"name": "test", "code": "test", "release_date": "2024-01-01", "total_cards": 0, "is_rotated": True, "rotation_date": None}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class CardRulingAPITest(APITestCase):
    def setUp(self):
        _dep_card_set = CardSet.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=1)
        _dep_card = Card.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        self.cardset = _dep_card_set
        self.card = _dep_card
        self.obj = CardRuling.objects.create(card=_dep_card, ruling_text="test", published_at="2024-01-01", source="test")
        self.list_url = reverse("card_ruling-list")
        self.detail_url = reverse("card_ruling-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "ruling_text": "test",
            "published_at": "2024-01-01",
            "source": "test",
            "card": self.card.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"ruling_text": "test"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class CardAbilityAPITest(APITestCase):
    def setUp(self):
        _dep_card_set = CardSet.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=1)
        _dep_card = Card.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        self.cardset = _dep_card_set
        self.card = _dep_card
        self.obj = CardAbility.objects.create(card=_dep_card, keyword="test", ability_text="test")
        self.list_url = reverse("card_ability-list")
        self.detail_url = reverse("card_ability-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "keyword": "test",
            "ability_text": "test",
            "card": self.card.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"keyword": "test"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

    def test_create_fails_when_keyword_ability_requires_keyword_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"ability_text": "test", "card": self.card.pk, "ability_type": "Keyword", "keyword": None}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class DeckAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        self.player = _dep_player
        self.obj = Deck.objects.create(player=_dep_player, name="test", is_public=True, wins=0, losses=0, draws=0, created_at="2024-01-01T00:00:00Z", updated_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("deck-list")
        self.detail_url = reverse("deck-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "name": "test",
            "is_public": True,
            "wins": 0,
            "losses": 0,
            "draws": 0,
            "created_at": "2024-01-01T00:00:00Z",
            "updated_at": "2024-01-01T00:00:00Z",
            "player": self.player.pk
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

    def test_create_fails_when_wins_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"name": "test", "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z", "player": self.player.pk, "is_tournament_legal": True, "is_public": True, "wins": -1}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_losses_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"name": "test", "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z", "player": self.player.pk, "is_tournament_legal": True, "is_public": True, "losses": -1}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_draws_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"name": "test", "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z", "player": self.player.pk, "is_tournament_legal": True, "is_public": True, "draws": -1}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_tournament_legal_deck_must_be_validated_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"name": "test", "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z", "player": self.player.pk, "is_tournament_legal": True, "is_public": False}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class DeckCardAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_deck = Deck.objects.create(name="test", created_at="2024-01-01T00:00:00Z", updated_at="2024-01-01T00:00:00Z", player=_dep_player)
        _dep_card_set = CardSet.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=1)
        _dep_card = Card.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        self.player = _dep_player
        self.deck = _dep_deck
        self.cardset = _dep_card_set
        self.card = _dep_card
        self.obj = DeckCard.objects.create(deck=_dep_deck, card=_dep_card, quantity=1)
        self.list_url = reverse("deck_card-list")
        self.detail_url = reverse("deck_card-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "quantity": 1,
            "deck": self.deck.pk,
            "card": self.card.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"quantity": 1}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

    def test_create_fails_when_quantity_range_violated(self):
        # Simple rule violated → 400
        data = {"deck": self.deck.pk, "card": self.card.pk, "quantity": 5}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class DeckSideboardCardAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_deck = Deck.objects.create(name="test", created_at="2024-01-01T00:00:00Z", updated_at="2024-01-01T00:00:00Z", player=_dep_player)
        _dep_card_set = CardSet.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=1)
        _dep_card = Card.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        self.player = _dep_player
        self.deck = _dep_deck
        self.cardset = _dep_card_set
        self.card = _dep_card
        self.obj = DeckSideboardCard.objects.create(deck=_dep_deck, card=_dep_card, quantity=1)
        self.list_url = reverse("deck_sideboard_card-list")
        self.detail_url = reverse("deck_sideboard_card-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "quantity": 1,
            "deck": self.deck.pk,
            "card": self.card.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"quantity": 1}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

    def test_create_fails_when_quantity_range_violated(self):
        # Simple rule violated → 400
        data = {"deck": self.deck.pk, "card": self.card.pk, "quantity": 5}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class DeckTagAPITest(APITestCase):
    def setUp(self):
        self.obj = DeckTag.objects.create(name="test")
        self.list_url = reverse("deck_tag-list")
        self.detail_url = reverse("deck_tag-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "name": "test"
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


class DeckTagAssignmentAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_deck = Deck.objects.create(name="test", created_at="2024-01-01T00:00:00Z", updated_at="2024-01-01T00:00:00Z", player=_dep_player)
        _dep_deck_tag = DeckTag.objects.create(name="test")
        self.player = _dep_player
        self.deck = _dep_deck
        self.decktag = _dep_deck_tag
        self.obj = DeckTagAssignment.objects.create(deck=_dep_deck, tag=_dep_deck_tag)
        self.list_url = reverse("deck_tag_assignment-list")
        self.detail_url = reverse("deck_tag_assignment-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "deck": self.deck.pk,
            "tag": self.decktag.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)
