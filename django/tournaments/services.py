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

    @staticmethod
    def is_ongoing(id):
        from .models import Season
        instance = Season.objects.get(pk=id)
        result = instance.is_ongoing()
        instance.save()
        return result


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

    @staticmethod
    def register_player(id, player_id, deck_id):
        from .models import Tournament
        instance = Tournament.objects.get(pk=id)
        instance.register_player(player_id, deck_id)
        instance.save()

    @staticmethod
    def is_full(id):
        from .models import Tournament
        instance = Tournament.objects.get(pk=id)
        result = instance.is_full()
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

    @staticmethod
    def promote_to_head(id):
        from .models import TournamentJudge
        instance = TournamentJudge.objects.get(pk=id)
        instance.promote_to_head()
        instance.save()

    @staticmethod
    def remove(id):
        from .models import TournamentJudge
        instance = TournamentJudge.objects.get(pk=id)
        instance.remove()
        instance.save()


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

    @staticmethod
    def is_time_expired(id):
        from .models import TournamentRound
        instance = TournamentRound.objects.get(pk=id)
        result = instance.is_time_expired()
        instance.save()
        return result


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
    def concede(id, player_id):
        from .models import Match
        instance = Match.objects.get(pk=id)
        instance.concede(player_id)
        instance.save()

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

    @staticmethod
    def duration_minutes(id):
        from .models import Game
        instance = Game.objects.get(pk=id)
        result = instance.duration_minutes()
        instance.save()
        return result


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

    @staticmethod
    def applies_to_placement(id):
        from .models import TournamentPrize
        instance = TournamentPrize.objects.get(pk=id)
        result = instance.applies_to_placement(placement)
        instance.save()
        return result

    @staticmethod
    def award_to_player(id, player_id):
        from .models import TournamentPrize
        instance = TournamentPrize.objects.get(pk=id)
        instance.award_to_player(player_id)
        instance.save()


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

    @staticmethod
    def claim(id):
        from .models import AwardedPrize
        instance = AwardedPrize.objects.get(pk=id)
        instance.claim()
        instance.save()

    # triggered by @on(claimed = true)
    @staticmethod
    def set_claimed(pk, value):
        from .models import AwardedPrize, AwardedPrizeClaimedChoices
        instance = AwardedPrize.objects.get(pk=pk)
        instance.claimed = value
        if value == AwardedPrizeClaimedChoices.TRUE:
            instance.claim()
        instance.save()
