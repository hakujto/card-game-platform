from django.test import TestCase
from ..models import Season, Tournament, TournamentJudge, TournamentRegistration, TournamentRound, Match, Game, TournamentPrize, AwardedPrize


class SeasonModelTest(TestCase):
    def setUp(self):
        self.obj = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-01")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class TournamentModelTest(TestCase):
    def setUp(self):
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-01")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        self.obj = Tournament.objects.create(season=_dep_season, organizer=_dep_player, name="test", max_players=0, start_time="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class TournamentJudgeModelTest(TestCase):
    def setUp(self):
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-01")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_tournament = Tournament.objects.create(name="test", max_players=0, start_time="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z", season=_dep_season, organizer=_dep_player)
        self.obj = TournamentJudge.objects.create(tournament=_dep_tournament, player=_dep_player)

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class TournamentRegistrationModelTest(TestCase):
    def setUp(self):
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-01")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_tournament = Tournament.objects.create(name="test", max_players=0, start_time="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z", season=_dep_season, organizer=_dep_player)
        from cards.models import Deck as _DeckCls
        _dep_deck = _DeckCls.objects.create(name="test", created_at="2024-01-01T00:00:00Z", updated_at="2024-01-01T00:00:00Z", player=_dep_player)
        self.obj = TournamentRegistration.objects.create(tournament=_dep_tournament, player=_dep_player, deck=_dep_deck, registered_at="2024-01-01T00:00:00Z")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class TournamentRoundModelTest(TestCase):
    def setUp(self):
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-01")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_tournament = Tournament.objects.create(name="test", max_players=0, start_time="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z", season=_dep_season, organizer=_dep_player)
        self.obj = TournamentRound.objects.create(tournament=_dep_tournament, round_number=0)

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class MatchModelTest(TestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        self.obj = Match.objects.create(player1=_dep_player)

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class GameModelTest(TestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_match = Match.objects.create(player1=_dep_player)
        self.obj = Game.objects.create(match=_dep_match, game_number=0)

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class TournamentPrizeModelTest(TestCase):
    def setUp(self):
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-01")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_tournament = Tournament.objects.create(name="test", max_players=0, start_time="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z", season=_dep_season, organizer=_dep_player)
        self.obj = TournamentPrize.objects.create(tournament=_dep_tournament, placement_from=0, placement_to=0, prize_type="Currency")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class AwardedPrizeModelTest(TestCase):
    def setUp(self):
        _dep_season = Season.objects.create(name="test", start_date="2024-01-01", end_date="2024-01-01")
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        _dep_tournament = Tournament.objects.create(name="test", max_players=0, start_time="2024-01-01T00:00:00Z", created_at="2024-01-01T00:00:00Z", season=_dep_season, organizer=_dep_player)
        _dep_tournament_prize = TournamentPrize.objects.create(placement_from=0, placement_to=0, prize_type="Currency", tournament=_dep_tournament)
        self.obj = AwardedPrize.objects.create(prize=_dep_tournament_prize, player=_dep_player, final_placement=0, awarded_at="2024-01-01T00:00:00Z")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)
