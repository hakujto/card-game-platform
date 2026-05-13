"""
Domain services for the Tournaments BC bounded context.
Place business logic that doesn't belong to a single model here.
"""


class SeasonService:
    """Domain service for Season aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new Season."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing Season."""
        raise NotImplementedError

    @staticmethod
    def activate(id):
        from .models import Season
        instance = Season.objects.get(pk=id)
        instance.activate()
        instance.save()

    @staticmethod
    def deactivate(id):
        from .models import Season
        instance = Season.objects.get(pk=id)
        instance.deactivate()
        instance.save()

    @staticmethod
    def finalize_rewards(id):
        from .models import Season
        instance = Season.objects.get(pk=id)
        instance.finalize_rewards()
        instance.save()


class TournamentService:
    """Domain service for Tournament aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new Tournament."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing Tournament."""
        raise NotImplementedError

    @staticmethod
    def start(id):
        from .models import Tournament
        instance = Tournament.objects.get(pk=id)
        instance.start()
        instance.save()

    @staticmethod
    def cancel(id):
        from .models import Tournament
        instance = Tournament.objects.get(pk=id)
        instance.cancel()
        instance.save()

    @staticmethod
    def complete(id):
        from .models import Tournament
        instance = Tournament.objects.get(pk=id)
        instance.complete()
        instance.save()

    @staticmethod
    def generate_round(id):
        from .models import Tournament
        instance = Tournament.objects.get(pk=id)
        instance.generate_round()
        instance.save()

    @staticmethod
    def calculate_prize_distribution(id):
        from .models import Tournament
        instance = Tournament.objects.get(pk=id)
        result = instance.calculate_prize_distribution()
        instance.save()
        return result


class TournamentJudgeService:
    """Domain service for TournamentJudge aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new TournamentJudge."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing TournamentJudge."""
        raise NotImplementedError


class TournamentRegistrationService:
    """Domain service for TournamentRegistration aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new TournamentRegistration."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing TournamentRegistration."""
        raise NotImplementedError

    @staticmethod
    def withdraw(id):
        from .models import TournamentRegistration
        instance = TournamentRegistration.objects.get(pk=id)
        instance.withdraw()
        instance.save()

    @staticmethod
    def disqualify(id, reason):
        from .models import TournamentRegistration
        instance = TournamentRegistration.objects.get(pk=id)
        instance.disqualify(reason)
        instance.save()

    @staticmethod
    def promote_from_waitlist(id):
        from .models import TournamentRegistration
        instance = TournamentRegistration.objects.get(pk=id)
        instance.promote_from_waitlist()
        instance.save()


class TournamentRoundService:
    """Domain service for TournamentRound aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new TournamentRound."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing TournamentRound."""
        raise NotImplementedError

    @staticmethod
    def start(id):
        from .models import TournamentRound
        instance = TournamentRound.objects.get(pk=id)
        instance.start()
        instance.save()

    @staticmethod
    def complete(id):
        from .models import TournamentRound
        instance = TournamentRound.objects.get(pk=id)
        instance.complete()
        instance.save()

    @staticmethod
    def generate_pairings(id):
        from .models import TournamentRound
        instance = TournamentRound.objects.get(pk=id)
        instance.generate_pairings()
        instance.save()


class MatchService:
    """Domain service for Match aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new Match."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing Match."""
        raise NotImplementedError

    @staticmethod
    def record_result(id, p1_wins, p2_wins):
        from .models import Match
        instance = Match.objects.get(pk=id)
        instance.record_result(p1_wins, p2_wins)
        instance.determine_winner()  # @after
        instance.save()

    @staticmethod
    def determine_winner(id):
        from .models import Match
        instance = Match.objects.get(pk=id)
        result = instance.determine_winner()
        instance.save()
        return result

    @staticmethod
    def draw(id):
        from .models import Match
        instance = Match.objects.get(pk=id)
        instance.draw()
        instance.save()


class GameService:
    """Domain service for Game aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new Game."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing Game."""
        raise NotImplementedError

    @staticmethod
    def record_winner(id, winner_side):
        from .models import Game
        instance = Game.objects.get(pk=id)
        instance.record_winner(winner_side)
        instance.save()


class TournamentPrizeService:
    """Domain service for TournamentPrize aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new TournamentPrize."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing TournamentPrize."""
        raise NotImplementedError


class AwardedPrizeService:
    """Domain service for AwardedPrize aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new AwardedPrize."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing AwardedPrize."""
        raise NotImplementedError
