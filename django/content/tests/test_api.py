from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from ..models import DraftSession, DraftParticipant, DraftPick, Article, ArticleTag, ArticleTagAssignment, ArticleComment, Stream


class DraftSessionAPITest(APITestCase):
    def setUp(self):
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=1)
        self.cardset = _dep_card_set
        self.obj = DraftSession.objects.create(card_set=_dep_card_set, seats=2, created_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("draft_session-list")
        self.detail_url = reverse("draft_session-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "seats": 2,
            "created_at": "2024-01-01T00:00:00Z",
            "card_set": self.cardset.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"seats": 2}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

    def test_create_fails_when_seats_range_violated(self):
        # Simple rule violated → 400
        data = {"created_at": "2024-01-01T00:00:00Z", "card_set": self.cardset.pk, "completed_at": "2024-01-01T00:00:00Z", "status": "Completed", "seats": 17}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_completed_at_requires_completed_status_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"created_at": "2024-01-01T00:00:00Z", "card_set": self.cardset.pk, "completed_at": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class DraftParticipantAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        self.player = _dep_player
        self.obj = DraftParticipant.objects.create(player=_dep_player, seat_number=1, joined_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("draft_participant-list")
        self.detail_url = reverse("draft_participant-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "seat_number": 1,
            "joined_at": "2024-01-01T00:00:00Z",
            "player": self.player.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"seat_number": 1}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

    def test_create_fails_when_seat_number_positive_violated(self):
        # Simple rule violated → 400
        data = {"seat_number": 0, "joined_at": "2024-01-01T00:00:00Z", "player": self.player.pk}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class DraftPickAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_draft_participant = DraftParticipant.objects.create(seat_number=1, joined_at="2024-01-01T00:00:00Z", player=_dep_player)
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=1)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        self.player = _dep_player
        self.draftparticipant = _dep_draft_participant
        self.cardset = _dep_card_set
        self.card = _dep_card
        self.obj = DraftPick.objects.create(participant=_dep_draft_participant, card=_dep_card, pick_number=1, pack_number=1, picked_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("draft_pick-list")
        self.detail_url = reverse("draft_pick-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "pick_number": 1,
            "pack_number": 1,
            "picked_at": "2024-01-01T00:00:00Z",
            "participant": self.draftparticipant.pk,
            "card": self.card.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"pick_number": 1}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

    def test_create_fails_when_pick_number_positive_violated(self):
        # Simple rule violated → 400
        data = {"pick_number": 0, "pack_number": 0, "picked_at": "2024-01-01T00:00:00Z", "participant": self.draftparticipant.pk, "card": self.card.pk}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_pack_number_range_violated(self):
        # Simple rule violated → 400
        data = {"pick_number": 0, "pack_number": 4, "picked_at": "2024-01-01T00:00:00Z", "participant": self.draftparticipant.pk, "card": self.card.pk}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class ArticleAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        self.player = _dep_player
        self.obj = Article.objects.create(author=_dep_player, title="test", slug="test", body="test", view_count=0, published_at="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z", updated_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("article-list")
        self.detail_url = reverse("article-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "title": "test",
            "slug": "test",
            "body": "test",
            "view_count": 0,
            "published_at": "2024-01-01T00:00:00Z",
            "created_at": "2024-01-01T00:00:00Z",
            "updated_at": "2024-01-01T00:00:00Z",
            "author": self.player.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"title": "test"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

    def test_create_fails_when_published_requires_published_at_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"title": "test", "slug": "test", "body": "test", "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z", "author": self.player.pk, "status": "Published", "published_at": None}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_view_count_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"title": "test", "slug": "test", "body": "test", "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z", "author": self.player.pk, "status": "Published", "published_at": "2024-01-01T00:00:00Z", "view_count": -1}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class ArticleTagAPITest(APITestCase):
    def setUp(self):
        self.obj = ArticleTag.objects.create(name="test", slug="test")
        self.list_url = reverse("article_tag-list")
        self.detail_url = reverse("article_tag-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "name": "test",
            "slug": "test"
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


class ArticleTagAssignmentAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_article = Article.objects.create(title="test", slug="test", body="test", created_at="2024-01-01T00:00:00Z", updated_at="2024-01-01T00:00:00Z", author=_dep_player)
        _dep_article_tag = ArticleTag.objects.create(name="test", slug="test")
        self.player = _dep_player
        self.article = _dep_article
        self.articletag = _dep_article_tag
        self.obj = ArticleTagAssignment.objects.create(article=_dep_article, tag=_dep_article_tag)
        self.list_url = reverse("article_tag_assignment-list")
        self.detail_url = reverse("article_tag_assignment-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "article": self.article.pk,
            "tag": self.articletag.pk
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


class ArticleCommentAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        self.player = _dep_player
        self.obj = ArticleComment.objects.create(author=_dep_player, body="test", created_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("article_comment-list")
        self.detail_url = reverse("article_comment-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "body": "test",
            "created_at": "2024-01-01T00:00:00Z",
            "author": self.player.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"body": "test"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class StreamAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        self.player = _dep_player
        self.obj = Stream.objects.create(streamer=_dep_player, title="test", stream_url="https://example.com", viewer_count_peak=0, scheduled_start="2024-01-01T00:00:00Z")
        self.list_url = reverse("stream-list")
        self.detail_url = reverse("stream-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "title": "test",
            "stream_url": "https://example.com",
            "viewer_count_peak": 0,
            "scheduled_start": "2024-01-01T00:00:00Z",
            "streamer": self.player.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"title": "test"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

    def test_create_fails_when_actual_start_requires_live_or_ended_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"title": "test", "stream_url": "https://example.com", "scheduled_start": "2024-01-01T00:00:00Z", "streamer": self.player.pk, "actual_start": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_ended_at_requires_ended_status_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"title": "test", "stream_url": "https://example.com", "scheduled_start": "2024-01-01T00:00:00Z", "streamer": self.player.pk, "ended_at": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_viewer_count_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"title": "test", "stream_url": "https://example.com", "scheduled_start": "2024-01-01T00:00:00Z", "streamer": self.player.pk, "actual_start": "2024-01-01T00:00:00Z", "status": "Ended", "ended_at": "2024-01-01T00:00:00Z", "viewer_count_peak": -1}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
