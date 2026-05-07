from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from .models import Season, Tournament, TournamentJudge, TournamentRegistration, TournamentRound, Match, Game, TournamentPrize, AwardedPrize


class SeasonAPITest(APITestCase):
    def setUp(self):
        self.obj = Season.objects.create(
            name="test",
            start_date="2024-01-01",
            end_date="2024-01-01",
            reward_description="test",
        )
        self.list_url = reverse("season-list")
        self.detail_url = reverse("season-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "test", "is_active": False}
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


class TournamentAPITest(APITestCase):
    def setUp(self):
        self.season = Season.objects.create()
        self.tournament_registration = TournamentRegistration.objects.create()
        self.tournament_round = TournamentRound.objects.create()
        self.tournament_prize = TournamentPrize.objects.create()
        # TODO: create related Player (cross-app dependency)
        self.obj = Tournament.objects.create(
            season=self.season,
            registrations=self.tournament_registration,
            rounds=self.tournament_round,
            prizes=self.tournament_prize,
            name="test",
            description="test",
            max_players=0,
            start_time="2024-01-01T00:00:00Z",
            end_time="2024-01-01T00:00:00Z",
            location="test",
            rules_text="test",
            created_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("tournament-list")
        self.detail_url = reverse("tournament-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"name": "test", "format": "test", "tournament_type": "test", "status": "test", "max_players": 0, "entry_fee": "0.00", "prize_pool": "0.00", "start_time": "2024-01-01T00:00:00Z", "is_online": False, "created_at": "2024-01-01T00:00:00Z"}
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


class TournamentJudgeAPITest(APITestCase):
    def setUp(self):
        self.tournament = Tournament.objects.create()
        # TODO: create related Player (cross-app dependency)
        self.obj = TournamentJudge.objects.create(
            tournament=self.tournament,
        )
        self.list_url = reverse("tournament_judge-list")
        self.detail_url = reverse("tournament_judge-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"role": "test"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"role": "test"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class TournamentRegistrationAPITest(APITestCase):
    def setUp(self):
        self.tournament = Tournament.objects.create()
        # TODO: create related Player (cross-app dependency)
        # TODO: create related Deck (cross-app dependency)
        self.obj = TournamentRegistration.objects.create(
            tournament=self.tournament,
            seed=0,
            final_standing=0,
            registered_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("tournament_registration-list")
        self.detail_url = reverse("tournament_registration-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"status": "test", "points_earned": 0, "registered_at": "2024-01-01T00:00:00Z"}
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


class TournamentRoundAPITest(APITestCase):
    def setUp(self):
        self.tournament = Tournament.objects.create()
        self.match = Match.objects.create()
        self.obj = TournamentRound.objects.create(
            tournament=self.tournament,
            matches=self.match,
            round_number=0,
            started_at="2024-01-01T00:00:00Z",
            ended_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("tournament_round-list")
        self.detail_url = reverse("tournament_round-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"round_number": 0, "status": "test", "time_limit_minutes": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"round_number": 0}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class MatchAPITest(APITestCase):
    def setUp(self):
        self.tournament_round = TournamentRound.objects.create()
        self.game = Game.objects.create()
        # TODO: create related Player (cross-app dependency)
        # TODO: create related Player (cross-app dependency)
        self.obj = Match.objects.create(
            round=self.tournament_round,
            games=self.game,
            table_number=0,
            started_at="2024-01-01T00:00:00Z",
            ended_at="2024-01-01T00:00:00Z",
            result_notes="test",
        )
        self.list_url = reverse("match-list")
        self.detail_url = reverse("match-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"status": "test", "player1_wins": 0, "player2_wins": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"table_number": 0}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class GameAPITest(APITestCase):
    def setUp(self):
        self.match = Match.objects.create()
        # TODO: create related Player (cross-app dependency)
        self.obj = Game.objects.create(
            match=self.match,
            game_number=0,
            winner_side="test",
            turns_played=0,
            duration_seconds=0,
            ended_by="test",
            replay_url="https://example.com",
        )
        self.list_url = reverse("game-list")
        self.detail_url = reverse("game-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"game_number": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"game_number": 0}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class TournamentPrizeAPITest(APITestCase):
    def setUp(self):
        self.tournament = Tournament.objects.create()
        self.obj = TournamentPrize.objects.create(
            tournament=self.tournament,
            placement_from=0,
            placement_to=0,
            prize_type="test",
            description="test",
            packs_count=0,
        )
        self.list_url = reverse("tournament_prize-list")
        self.detail_url = reverse("tournament_prize-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"placement_from": 0, "placement_to": 0, "prize_type": "test", "amount": "0.00", "season_points": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"placement_from": 0}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class AwardedPrizeAPITest(APITestCase):
    def setUp(self):
        self.tournament_prize = TournamentPrize.objects.create()
        # TODO: create related Player (cross-app dependency)
        self.obj = AwardedPrize.objects.create(
            prize=self.tournament_prize,
            final_placement=0,
            awarded_at="2024-01-01T00:00:00Z",
            claimed_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("awarded_prize-list")
        self.detail_url = reverse("awarded_prize-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"final_placement": 0, "awarded_at": "2024-01-01T00:00:00Z", "claimed": False}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"final_placement": 0}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)
