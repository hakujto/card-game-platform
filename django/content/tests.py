from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from .models import DraftSession, DraftParticipant, DraftPick, Article, ArticleTag, ArticleTagAssignment, ArticleComment, Stream


class DraftSessionAPITest(APITestCase):
    def setUp(self):
        self.draft_participant = DraftParticipant.objects.create()
        # TODO: create related CardSet (cross-app dependency)
        self.obj = DraftSession.objects.create(
            participants=self.draft_participant,
            created_at="2024-01-01T00:00:00Z",
            completed_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("draft_session-list")
        self.detail_url = reverse("draft_session-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"status": "test", "draft_type": "test", "seats": 0, "created_at": "2024-01-01T00:00:00Z"}
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


class DraftParticipantAPITest(APITestCase):
    def setUp(self):
        self.draft_session = DraftSession.objects.create()
        self.draft_pick = DraftPick.objects.create()
        # TODO: create related Player (cross-app dependency)
        self.obj = DraftParticipant.objects.create(
            session=self.draft_session,
            drafted_cards=self.draft_pick,
            seat_number=0,
            joined_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("draft_participant-list")
        self.detail_url = reverse("draft_participant-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"seat_number": 0, "joined_at": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"seat_number": 0}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class DraftPickAPITest(APITestCase):
    def setUp(self):
        self.draft_participant = DraftParticipant.objects.create()
        # TODO: create related Card (cross-app dependency)
        self.obj = DraftPick.objects.create(
            participant=self.draft_participant,
            pick_number=0,
            pack_number=0,
            picked_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("draft_pick-list")
        self.detail_url = reverse("draft_pick-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"pick_number": 0, "pack_number": 0, "picked_at": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"pick_number": 0}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class ArticleAPITest(APITestCase):
    def setUp(self):
        self.article_comment = ArticleComment.objects.create()
        # TODO: create related Player (cross-app dependency)
        # TODO: create related Deck (cross-app dependency)
        self.obj = Article.objects.create(
            comments=self.article_comment,
            title="test",
            slug="test",
            body="test",
            excerpt="test",
            cover_image_url="https://example.com",
            published_at="2024-01-01T00:00:00Z",
            created_at="2024-01-01T00:00:00Z",
            updated_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("article-list")
        self.detail_url = reverse("article-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"title": "test", "slug": "test", "body": "test", "status": "test", "article_type": "test", "view_count": 0, "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:00Z"}
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


class ArticleTagAPITest(APITestCase):
    def setUp(self):
        self.obj = ArticleTag.objects.create(
            name="test",
            slug="test",
        )
        self.list_url = reverse("article_tag-list")
        self.detail_url = reverse("article_tag-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"name": "test", "slug": "test"}
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
        self.article = Article.objects.create()
        self.article_tag = ArticleTag.objects.create()
        self.obj = ArticleTagAssignment.objects.create(
            article=self.article,
            tag=self.article_tag,
        )
        self.list_url = reverse("article_tag_assignment-list")
        self.detail_url = reverse("article_tag_assignment-detail", args=[self.obj.pk])

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


class ArticleCommentAPITest(APITestCase):
    def setUp(self):
        self.article = Article.objects.create()
        # TODO: create related Player (cross-app dependency)
        self.obj = ArticleComment.objects.create(
            article=self.article,
            body="test",
            created_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("article_comment-list")
        self.detail_url = reverse("article_comment-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"body": "test", "is_hidden": False, "created_at": "2024-01-01T00:00:00Z"}
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
        # TODO: create related Tournament (cross-app dependency)
        # TODO: create related Player (cross-app dependency)
        self.obj = Stream.objects.create(
            title="test",
            stream_url="https://example.com",
            scheduled_start="2024-01-01T00:00:00Z",
            actual_start="2024-01-01T00:00:00Z",
            ended_at="2024-01-01T00:00:00Z",
            vod_url="https://example.com",
        )
        self.list_url = reverse("stream-list")
        self.detail_url = reverse("stream-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"title": "test", "stream_url": "https://example.com", "platform": "test", "status": "test", "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00Z"}
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
