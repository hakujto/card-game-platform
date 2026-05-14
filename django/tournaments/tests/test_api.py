from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from ..models import Season, Tournament, TournamentJudge, TournamentRegistration, TournamentRound, Match, Game, TournamentPrize, AwardedPrize


class SeasonAPITest(APITestCase):
    def setUp(self):
        self.obj = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-02")
        self.list_url = reverse("season-list")
        self.detail_url = reverse("season-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "name": "test",
            "start_date": "2024-01-01",
            "end_date": "2024-01-02"
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
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-02")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        self.season = _dep_season
        self.player = _dep_player
        self.obj = Tournament.objects.create(season=_dep_season, organizer=_dep_player, name="test", max_players=2, entry_fee=0, prize_pool=0, start_time="2024-01-01T00:00:00Z", end_time=None, created_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("tournament-list")
        self.detail_url = reverse("tournament-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "name": "test",
            "max_players": 2,
            "entry_fee": 0,
            "prize_pool": 0,
            "start_time": "2024-01-01T00:00:00Z",
            "end_time": None,
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

    def test_create_fails_when_max_players_positive_violated(self):
        # Simple rule violated → 400
        data = {"name": "test", "max_players": 513, "start_time": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "end_time": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_entry_fee_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"name": "test", "max_players": 0, "start_time": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "end_time": "2024-01-01T00:00:00Z", "entry_fee": -1}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_prize_pool_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"name": "test", "max_players": 0, "start_time": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "end_time": "2024-01-01T00:00:00Z", "prize_pool": -1}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_end_time_after_start_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"name": "test", "max_players": 0, "start_time": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "end_time": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class TournamentJudgeAPITest(APITestCase):
    def setUp(self):
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-02")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_tournament = Tournament.objects.create(name="test", max_players=2, start_time="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z", season=_dep_season, organizer=_dep_player)
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
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-02")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_tournament = Tournament.objects.create(name="test", max_players=2, start_time="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z", season=_dep_season, organizer=_dep_player)
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
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-02")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_tournament = Tournament.objects.create(name="test", max_players=2, start_time="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z", season=_dep_season, organizer=_dep_player)
        self.season = _dep_season
        self.player = _dep_player
        self.tournament = _dep_tournament
        self.obj = TournamentRound.objects.create(tournament=_dep_tournament, round_number=0, ended_at=None)
        self.list_url = reverse("tournament_round-list")
        self.detail_url = reverse("tournament_round-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "round_number": 0,
            "ended_at": None,
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

    def test_create_fails_when_ended_after_started_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"round_number": 0, "ended_at": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class MatchAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        self.player = _dep_player
        self.obj = Match.objects.create(player1=_dep_player, player1_wins=0, player2_wins=0)
        self.list_url = reverse("match-list")
        self.detail_url = reverse("match-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
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

    def test_create_fails_when_wins_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"status": "BYE", "player2": None, "player1_wins": -1}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_max_three_games_violated(self):
        # Simple rule violated → 400
        data = {"status": "BYE", "player2": None, "player1_wins": 3}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_bye_has_no_player2_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"status": "BYE", "player2": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class GameAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_match = Match.objects.create(player1=_dep_player)
        self.player = _dep_player
        self.match = _dep_match
        self.obj = Game.objects.create(match=_dep_match, game_number=1, turns_played=1, duration_seconds=1)
        self.list_url = reverse("game-list")
        self.detail_url = reverse("game-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "game_number": 1,
            "turns_played": 1,
            "duration_seconds": 1,
            "match": self.match.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"game_number": 1}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

    def test_create_fails_when_game_number_range_violated(self):
        # Simple rule violated → 400
        data = {"game_number": 4, "turns_played": 1, "duration_seconds": 1}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_turns_played_positive_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"game_number": 0, "turns_played": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_duration_positive_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"game_number": 0, "duration_seconds": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class TournamentPrizeAPITest(APITestCase):
    def setUp(self):
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-02")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_tournament = Tournament.objects.create(name="test", max_players=2, start_time="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z", season=_dep_season, organizer=_dep_player)
        self.season = _dep_season
        self.player = _dep_player
        self.tournament = _dep_tournament
        self.obj = TournamentPrize.objects.create(tournament=_dep_tournament, placement_from=1, placement_to=1, prize_type="Currency", amount=0)
        self.list_url = reverse("tournament_prize-list")
        self.detail_url = reverse("tournament_prize-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "placement_from": 1,
            "placement_to": 1,
            "prize_type": "Currency",
            "amount": 0,
            "tournament": self.tournament.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"placement_from": 1}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

    def test_create_fails_when_placement_from_positive_violated(self):
        # Simple rule violated → 400
        data = {"placement_from": 0, "placement_to": 0, "prize_type": "Currency"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_amount_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"placement_from": 0, "placement_to": 0, "prize_type": "Currency", "amount": -1}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class AwardedPrizeAPITest(APITestCase):
    def setUp(self):
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-02")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_tournament = Tournament.objects.create(name="test", max_players=2, start_time="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z", season=_dep_season, organizer=_dep_player)
        _dep_tournament_prize = TournamentPrize.objects.create(placement_from=1, placement_to=1, prize_type="Currency", tournament=_dep_tournament)
        self.season = _dep_season
        self.player = _dep_player
        self.tournament = _dep_tournament
        self.tournamentprize = _dep_tournament_prize
        self.obj = AwardedPrize.objects.create(prize=_dep_tournament_prize, player=_dep_player, final_placement=1, awarded_at="2024-01-01T00:00:00Z", claimed_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("awarded_prize-list")
        self.detail_url = reverse("awarded_prize-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "final_placement": 1,
            "awarded_at": "2024-01-01T00:00:00Z",
            "claimed_at": "2024-01-01T00:00:00Z",
            "prize": self.tournamentprize.pk,
            "player": self.player.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"final_placement": 1}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

    def test_create_fails_when_claimed_requires_claimed_at_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"final_placement": 0, "awarded_at": "2024-01-01T00:00:00Z", "claimed": True, "claimed_at": None}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_final_placement_positive_violated(self):
        # Simple rule violated → 400
        data = {"final_placement": 0, "awarded_at": "2024-01-01T00:00:00Z", "claimed": True, "claimed_at": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
