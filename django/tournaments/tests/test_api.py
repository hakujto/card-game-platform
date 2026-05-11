from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from ..models import Season, Tournament, TournamentJudge, TournamentRegistration, TournamentRound, Match, Game, TournamentPrize, AwardedPrize


class SeasonAPITest(APITestCase):
    def setUp(self):
        self.obj = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-01")
        self.list_url = reverse("season-list")
        self.detail_url = reverse("season-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "name": "test",
            "start_date": "2024-01-01",
            "end_date": "2024-01-01",
            "format": "Standard",
            "is_active": False
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


class TournamentAPITest(APITestCase):
    def setUp(self):
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-01")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        self.season = _dep_season
        self.player = _dep_player
        self.obj = Tournament.objects.create(season=_dep_season, organizer=_dep_player, name="test", max_players=0, start_time="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("tournament-list")
        self.detail_url = reverse("tournament-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "name": "test",
            "format": "Standard",
            "tournament_type": "Swiss",
            "status": "Draft",
            "max_players": 0,
            "entry_fee": "0.00",
            "prize_pool": "0.00",
            "start_time": "2024-01-01T00:00:00Z",
            "is_online": False,
            "created_at": "2024-01-01T00:00:00Z",
            "season": self.season.pk,
            "organizer": self.player.pk
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


class TournamentJudgeAPITest(APITestCase):
    def setUp(self):
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-01")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_tournament = Tournament.objects.create(name="test", max_players=0, start_time="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z", season=_dep_season, organizer=_dep_player)
        self.season = _dep_season
        self.player = _dep_player
        self.tournament = _dep_tournament
        self.obj = TournamentJudge.objects.create(tournament=_dep_tournament, player=_dep_player)
        self.list_url = reverse("tournament_judge-list")
        self.detail_url = reverse("tournament_judge-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "role": "HeadJudge",
            "tournament": self.tournament.pk,
            "player": self.player.pk
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


class TournamentRegistrationAPITest(APITestCase):
    def setUp(self):
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-01")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_tournament = Tournament.objects.create(name="test", max_players=0, start_time="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z", season=_dep_season, organizer=_dep_player)
        from cards.models import Deck as _DeckCls
        _dep_deck = _DeckCls.objects.create(name="test", created_at="2024-01-01T00:00:00Z", updated_at="2024-01-01T00:00:00Z", player=_dep_player)
        self.season = _dep_season
        self.player = _dep_player
        self.tournament = _dep_tournament
        self.deck = _dep_deck
        self.obj = TournamentRegistration.objects.create(tournament=_dep_tournament, player=_dep_player, deck=_dep_deck, registered_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("tournament_registration-list")
        self.detail_url = reverse("tournament_registration-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "status": "Registered",
            "points_earned": 0,
            "registered_at": "2024-01-01T00:00:00Z",
            "tournament": self.tournament.pk,
            "player": self.player.pk,
            "deck": self.deck.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"seed": 0}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class TournamentRoundAPITest(APITestCase):
    def setUp(self):
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-01")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_tournament = Tournament.objects.create(name="test", max_players=0, start_time="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z", season=_dep_season, organizer=_dep_player)
        self.season = _dep_season
        self.player = _dep_player
        self.tournament = _dep_tournament
        self.obj = TournamentRound.objects.create(tournament=_dep_tournament, round_number=0)
        self.list_url = reverse("tournament_round-list")
        self.detail_url = reverse("tournament_round-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "round_number": 0,
            "status": "Pending",
            "time_limit_minutes": 0,
            "tournament": self.tournament.pk
        }
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
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        self.player = _dep_player
        self.obj = Match.objects.create(player1=_dep_player)
        self.list_url = reverse("match-list")
        self.detail_url = reverse("match-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "status": "Pending",
            "player1_wins": 0,
            "player2_wins": 0,
            "player1": self.player.pk
        }
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
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_match = Match.objects.create(player1=_dep_player)
        self.player = _dep_player
        self.match = _dep_match
        self.obj = Game.objects.create(match=_dep_match, game_number=0)
        self.list_url = reverse("game-list")
        self.detail_url = reverse("game-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "game_number": 0,
            "match": self.match.pk
        }
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
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-01")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_tournament = Tournament.objects.create(name="test", max_players=0, start_time="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z", season=_dep_season, organizer=_dep_player)
        self.season = _dep_season
        self.player = _dep_player
        self.tournament = _dep_tournament
        self.obj = TournamentPrize.objects.create(tournament=_dep_tournament, placement_from=0, placement_to=0, prize_type="Currency")
        self.list_url = reverse("tournament_prize-list")
        self.detail_url = reverse("tournament_prize-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "placement_from": 0,
            "placement_to": 0,
            "prize_type": "Currency",
            "amount": "0.00",
            "season_points": 0,
            "tournament": self.tournament.pk
        }
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
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-01")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_tournament = Tournament.objects.create(name="test", max_players=0, start_time="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z", season=_dep_season, organizer=_dep_player)
        _dep_tournament_prize = TournamentPrize.objects.create(placement_from=0, placement_to=0, prize_type="Currency", tournament=_dep_tournament)
        self.season = _dep_season
        self.player = _dep_player
        self.tournament = _dep_tournament
        self.tournamentprize = _dep_tournament_prize
        self.obj = AwardedPrize.objects.create(prize=_dep_tournament_prize, player=_dep_player, final_placement=0, awarded_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("awarded_prize-list")
        self.detail_url = reverse("awarded_prize-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "final_placement": 0,
            "awarded_at": "2024-01-01T00:00:00Z",
            "claimed": False,
            "prize": self.tournamentprize.pk,
            "player": self.player.pk
        }
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
