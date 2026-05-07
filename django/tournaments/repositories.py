"""
Repository layer for the Tournaments BC bounded context.
Abstracts data access from domain logic.
"""


class SeasonRepository:
    """Repository for Season."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import Season
        return Season.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import Season
        return Season.objects.all()


class TournamentRepository:
    """Repository for Tournament."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import Tournament
        return Tournament.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import Tournament
        return Tournament.objects.all()


class TournamentJudgeRepository:
    """Repository for TournamentJudge."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import TournamentJudge
        return TournamentJudge.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import TournamentJudge
        return TournamentJudge.objects.all()


class TournamentRegistrationRepository:
    """Repository for TournamentRegistration."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import TournamentRegistration
        return TournamentRegistration.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import TournamentRegistration
        return TournamentRegistration.objects.all()


class TournamentRoundRepository:
    """Repository for TournamentRound."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import TournamentRound
        return TournamentRound.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import TournamentRound
        return TournamentRound.objects.all()


class MatchRepository:
    """Repository for Match."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import Match
        return Match.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import Match
        return Match.objects.all()


class GameRepository:
    """Repository for Game."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import Game
        return Game.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import Game
        return Game.objects.all()


class TournamentPrizeRepository:
    """Repository for TournamentPrize."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import TournamentPrize
        return TournamentPrize.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import TournamentPrize
        return TournamentPrize.objects.all()


class AwardedPrizeRepository:
    """Repository for AwardedPrize."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import AwardedPrize
        return AwardedPrize.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import AwardedPrize
        return AwardedPrize.objects.all()
