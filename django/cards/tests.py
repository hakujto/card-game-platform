from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from .models import Card, CardSet, CardRuling, CardAbility, Deck, DeckCard, DeckSideboardCard, DeckTag, DeckTagAssignment


class CardAPITest(APITestCase):
    def setUp(self):
        self.card_set = CardSet.objects.create()
        self.card_ruling = CardRuling.objects.create()
        self.card_ability = CardAbility.objects.create()
        self.obj = Card.objects.create(
            set=self.card_set,
            rulings=self.card_ruling,
            abilities=self.card_ability,
            name="test",
            mana_colors="test",
            attack=0,
            defense=0,
            loyalty=0,
            description="test",
            flavor_text="test",
            image_url="https://example.com",
            artist_name="test",
            legal_formats="test",
        )
        self.list_url = reverse("card-list")
        self.detail_url = reverse("card-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"name": "test", "card_type": "test", "rarity": "test", "mana_cost": 0, "mana_colors": "test", "description": "test", "legal_formats": "test", "is_banned": False, "is_restricted": False, "power_level": 0}
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


class CardSetAPITest(APITestCase):
    def setUp(self):
        self.obj = CardSet.objects.create(
            name="test",
            code="test",
            release_date="2024-01-01",
            total_cards=0,
            description="test",
            logo_url="https://example.com",
        )
        self.list_url = reverse("card_set-list")
        self.detail_url = reverse("card_set-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "test", "total_cards": 0}
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


class CardRulingAPITest(APITestCase):
    def setUp(self):
        self.card = Card.objects.create()
        self.obj = CardRuling.objects.create(
            card=self.card,
            ruling_text="test",
            published_at="2024-01-01",
            source="test",
        )
        self.list_url = reverse("card_ruling-list")
        self.detail_url = reverse("card_ruling-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"ruling_text": "test", "published_at": "2024-01-01", "source": "test"}
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
        self.card = Card.objects.create()
        self.obj = CardAbility.objects.create(
            card=self.card,
            keyword="test",
            ability_text="test",
            timing="test",
        )
        self.list_url = reverse("card_ability-list")
        self.detail_url = reverse("card_ability-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"ability_type": "test", "ability_text": "test"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"ability_type": "test"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class DeckAPITest(APITestCase):
    def setUp(self):
        # TODO: create related Player (cross-app dependency)
        self.obj = Deck.objects.create(
            name="test",
            description="test",
            archetype="test",
            created_at="2024-01-01T00:00:00Z",
            updated_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("deck-list")
        self.detail_url = reverse("deck-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"name": "test", "format": "test", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"}
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


class DeckCardAPITest(APITestCase):
    def setUp(self):
        self.deck = Deck.objects.create()
        self.card = Card.objects.create()
        self.obj = DeckCard.objects.create(
            deck=self.deck,
            card=self.card,
        )
        self.list_url = reverse("deck_card-list")
        self.detail_url = reverse("deck_card-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"quantity": 0, "is_commander": False}
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


class DeckSideboardCardAPITest(APITestCase):
    def setUp(self):
        self.deck = Deck.objects.create()
        self.card = Card.objects.create()
        self.obj = DeckSideboardCard.objects.create(
            deck=self.deck,
            card=self.card,
        )
        self.list_url = reverse("deck_sideboard_card-list")
        self.detail_url = reverse("deck_sideboard_card-detail", args=[self.obj.pk])

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


class DeckTagAPITest(APITestCase):
    def setUp(self):
        self.obj = DeckTag.objects.create(
            name="test",
            color="test",
        )
        self.list_url = reverse("deck_tag-list")
        self.detail_url = reverse("deck_tag-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"name": "test"}
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
        self.deck = Deck.objects.create()
        self.deck_tag = DeckTag.objects.create()
        self.obj = DeckTagAssignment.objects.create(
            deck=self.deck,
            tag=self.deck_tag,
        )
        self.list_url = reverse("deck_tag_assignment-list")
        self.detail_url = reverse("deck_tag_assignment-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {}
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
