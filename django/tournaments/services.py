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
