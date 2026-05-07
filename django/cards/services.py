"""
Domain services for the Cards BC bounded context.
Place business logic that doesn't belong to a single model here.
"""


class CardService:
    """Domain service for Card aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new Card."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing Card."""
        raise NotImplementedError


class CardSetService:
    """Domain service for CardSet aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new CardSet."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing CardSet."""
        raise NotImplementedError


class CardRulingService:
    """Domain service for CardRuling aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new CardRuling."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing CardRuling."""
        raise NotImplementedError


class CardAbilityService:
    """Domain service for CardAbility aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new CardAbility."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing CardAbility."""
        raise NotImplementedError


class DeckService:
    """Domain service for Deck aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new Deck."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing Deck."""
        raise NotImplementedError


class DeckCardService:
    """Domain service for DeckCard aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new DeckCard."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing DeckCard."""
        raise NotImplementedError


class DeckSideboardCardService:
    """Domain service for DeckSideboardCard aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new DeckSideboardCard."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing DeckSideboardCard."""
        raise NotImplementedError


class DeckTagService:
    """Domain service for DeckTag aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new DeckTag."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing DeckTag."""
        raise NotImplementedError


class DeckTagAssignmentService:
    """Domain service for DeckTagAssignment aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new DeckTagAssignment."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing DeckTagAssignment."""
        raise NotImplementedError
