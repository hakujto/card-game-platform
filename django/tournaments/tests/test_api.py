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

    def test_search_returns_200(self):
        res = self.client.get(self.list_url + "?q=test")
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

    def test_search_returns_200(self):
        res = self.client.get(self.list_url + "?q=test")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "name": "test",
            "max_players": 2,
            "entry_fee": 0,
            "prize_pool": 0,
            "startTime": "2024-01-01T00:00:00Z",
            "endTime": None,
            "createdAt": "2024-01-01T00:00:00Z",
            "season": self.season.pk,
            "organizer": self.player.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"description": "test"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_fails_when_max_players_positive_violated(self):
        # Simple rule violated → 400
        data = {"name": "test", "max_players": 513, "startTime": "2024-01-01T00:00:00Z", "createdAt": "2024-01-01T00:00:00Z", "season": self.season.pk, "organizer": self.player.pk, "endTime": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_entry_fee_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"name": "test", "max_players": 0, "startTime": "2024-01-01T00:00:00Z", "createdAt": "2024-01-01T00:00:00Z", "season": self.season.pk, "organizer": self.player.pk, "endTime": "2024-01-01T00:00:00Z", "entry_fee": -1}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_prize_pool_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"name": "test", "max_players": 0, "startTime": "2024-01-01T00:00:00Z", "createdAt": "2024-01-01T00:00:00Z", "season": self.season.pk, "organizer": self.player.pk, "endTime": "2024-01-01T00:00:00Z", "prize_pool": -1}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_end_time_after_start_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"name": "test", "max_players": 0, "startTime": "2024-01-01T00:00:00Z", "createdAt": "2024-01-01T00:00:00Z", "season": self.season.pk, "organizer": self.player.pk, "endTime": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_transition_draft_to_registration_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="draft_to_registration_Admin")
        _role_user.role = "Admin"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Draft"
        self.obj.name = "test"  # @on: name != null
        self.obj.start_time = "2024-01-01T00:00:00Z"  # @on: start_time != null
        self.obj.save()
        url = reverse("tournament-transition-draft-to-registration", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Registration")

    def test_transition_registration_to_ongoing_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="registration_to_ongoing_Admin")
        _role_user.role = "Admin"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Registration"
        self.obj.save()
        url = reverse("tournament-transition-registration-to-ongoing", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Ongoing")

    def test_transition_registration_to_cancelled_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="registration_to_cancelled_Admin")
        _role_user.role = "Admin"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Registration"
        self.obj.save()
        url = reverse("tournament-transition-registration-to-cancelled", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Cancelled")

    def test_transition_ongoing_to_completed_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="ongoing_to_completed_Admin")
        _role_user.role = "Admin"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Ongoing"
        self.obj.save()
        url = reverse("tournament-transition-ongoing-to-completed", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Completed")

    def test_transition_ongoing_to_cancelled_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="ongoing_to_cancelled_Admin")
        _role_user.role = "Admin"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Ongoing"
        self.obj.save()
        url = reverse("tournament-transition-ongoing-to-cancelled", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Cancelled")

    def test_transition_completed_to_draft_is_denied(self):
        url = reverse("tournament-transition-completed-to-draft", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, 409)

    def test_transition_cancelled_to_draft_is_denied(self):
        url = reverse("tournament-transition-cancelled-to-draft", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, 409)


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
        self.obj = TournamentRegistration.objects.create(tournament=_dep_tournament, player=_dep_player, deck=_dep_deck, seed=1, final_standing=1, points_earned=0, registered_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("tournament_registration-list")
        self.detail_url = reverse("tournament_registration-detail", args=[self.obj.pk])
        from django.contrib.auth import get_user_model
        _owner_user, _ = get_user_model().objects.get_or_create(pk=_dep_player.pk, defaults={"username": f"owner_{_dep_player.pk}"})
        self.client.force_authenticate(user=_owner_user)

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "seed": 1,
            "final_standing": 1,
            "points_earned": 0,
            "registeredAt": "2024-01-01T00:00:00Z",
            "tournament": self.tournament.pk,
            "player": self.player.pk,
            "deck": self.deck.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_fails_when_points_earned_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"registeredAt": "2024-01-01T00:00:00Z", "tournament": self.tournament.pk, "player": self.player.pk, "deck": self.deck.pk, "final_standing": 1, "seed": 1, "points_earned": -1}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_final_standing_positive_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"registeredAt": "2024-01-01T00:00:00Z", "tournament": self.tournament.pk, "player": self.player.pk, "deck": self.deck.pk, "final_standing": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_seed_positive_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"registeredAt": "2024-01-01T00:00:00Z", "tournament": self.tournament.pk, "player": self.player.pk, "deck": self.deck.pk, "seed": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class TournamentRoundAPITest(APITestCase):
    def setUp(self):
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-02")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_tournament = Tournament.objects.create(name="test", max_players=2, start_time="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z", season=_dep_season, organizer=_dep_player)
        self.season = _dep_season
        self.player = _dep_player
        self.tournament = _dep_tournament
        self.obj = TournamentRound.objects.create(tournament=_dep_tournament, round_number=1, started_at="2024-01-01T00:00:00Z", ended_at=None, time_limit_minutes=1)
        self.list_url = reverse("tournament_round-list")
        self.detail_url = reverse("tournament_round-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "round_number": 1,
            "startedAt": "2024-01-01T00:00:00Z",
            "endedAt": None,
            "time_limit_minutes": 1,
            "tournament": self.tournament.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_fails_when_ended_after_started_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"round_number": 0, "tournament": self.tournament.pk, "endedAt": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_completed_requires_started_at_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"round_number": 0, "tournament": self.tournament.pk, "status": "Completed", "startedAt": None}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_round_number_positive_violated(self):
        # Simple rule violated → 400
        data = {"round_number": 0, "tournament": self.tournament.pk, "endedAt": "2024-01-01T00:00:00Z", "status": "Completed", "startedAt": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_time_limit_positive_violated(self):
        # Simple rule violated → 400
        data = {"round_number": 0, "tournament": self.tournament.pk, "endedAt": "2024-01-01T00:00:00Z", "status": "Completed", "startedAt": "2024-01-01T00:00:00Z", "time_limit_minutes": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class MatchAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        self.player = _dep_player
        self.obj = Match.objects.create(player1=_dep_player, player1_wins=0, player2_wins=0, started_at="2024-01-01T00:00:00Z", ended_at=None)
        self.list_url = reverse("match-list")
        self.detail_url = reverse("match-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "player1_wins": 0,
            "player2_wins": 0,
            "startedAt": "2024-01-01T00:00:00Z",
            "endedAt": None,
            "player1": self.player.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_fails_when_wins_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"player1": self.player.pk, "status": "Completed", "player2": None, "endedAt": "2024-01-01T00:00:00Z", "startedAt": "2024-01-01T00:00:00Z", "player1_wins": -1}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_max_three_games_violated(self):
        # Simple rule violated → 400
        data = {"player1": self.player.pk, "status": "Completed", "player2": None, "endedAt": "2024-01-01T00:00:00Z", "startedAt": "2024-01-01T00:00:00Z", "player1_wins": 3}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_bye_has_no_player2_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"player1": self.player.pk, "status": "BYE", "player2": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_ended_after_started_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"player1": self.player.pk, "endedAt": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_completed_requires_started_at_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"player1": self.player.pk, "status": "Completed", "startedAt": None}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_transition_pending_to_active_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="pending_to_active_Judge")
        _role_user.role = "Judge"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Pending"
        self.obj.save()
        url = reverse("match-transition-pending-to-active", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Active")

    def test_transition_active_to_completed_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="active_to_completed_Judge")
        _role_user.role = "Judge"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Active"
        self.obj.save()
        url = reverse("match-transition-active-to-completed", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Completed")

    def test_transition_active_to_draw_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="active_to_draw_Judge")
        _role_user.role = "Judge"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Active"
        self.obj.save()
        url = reverse("match-transition-active-to-draw", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Draw")

    def test_transition_pending_to_bye_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="pending_to_bye_Judge")
        _role_user.role = "Judge"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Pending"
        self.obj.save()
        url = reverse("match-transition-pending-to-bye", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "BYE")

    def test_transition_completed_to_active_is_denied(self):
        url = reverse("match-transition-completed-to-active", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, 409)

    def test_transition_draw_to_active_is_denied(self):
        url = reverse("match-transition-draw-to-active", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, 409)

    def test_transition_bye_to_active_is_denied(self):
        url = reverse("match-transition-bye-to-active", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, 409)


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

    def test_create_fails_when_game_number_range_violated(self):
        # Simple rule violated → 400
        data = {"game_number": 4, "match": self.match.pk, "turns_played": 1, "duration_seconds": 1, "winner_side": "Player1", "winner": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_turns_played_positive_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"game_number": 0, "match": self.match.pk, "turns_played": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_duration_positive_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"game_number": 0, "match": self.match.pk, "duration_seconds": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_draw_has_no_winner_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"game_number": 0, "match": self.match.pk, "winner_side": "Draw", "winner": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_non_draw_requires_winner_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"game_number": 0, "match": self.match.pk, "winner_side": "Player1", "winner": None}
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
        data = {"placement_from": 0, "placement_to": 0, "prize_type": "Currency", "tournament": self.tournament.pk}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_amount_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"placement_from": 0, "placement_to": 0, "prize_type": "Currency", "tournament": self.tournament.pk, "amount": -1}
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

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
