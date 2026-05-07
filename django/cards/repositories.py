"""
Repository layer for the Cards BC bounded context.
Abstracts data access from domain logic.
"""


class CardRepository:
    """Repository for Card."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import Card
        return Card.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import Card
        return Card.objects.all()


class CardSetRepository:
    """Repository for CardSet."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import CardSet
        return CardSet.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import CardSet
        return CardSet.objects.all()


class CardRulingRepository:
    """Repository for CardRuling."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import CardRuling
        return CardRuling.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import CardRuling
        return CardRuling.objects.all()


class CardAbilityRepository:
    """Repository for CardAbility."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import CardAbility
        return CardAbility.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import CardAbility
        return CardAbility.objects.all()


class DeckRepository:
    """Repository for Deck."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import Deck
        return Deck.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import Deck
        return Deck.objects.all()


class DeckCardRepository:
    """Repository for DeckCard."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import DeckCard
        return DeckCard.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import DeckCard
        return DeckCard.objects.all()


class DeckSideboardCardRepository:
    """Repository for DeckSideboardCard."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import DeckSideboardCard
        return DeckSideboardCard.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import DeckSideboardCard
        return DeckSideboardCard.objects.all()


class DeckTagRepository:
    """Repository for DeckTag."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import DeckTag
        return DeckTag.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import DeckTag
        return DeckTag.objects.all()


class DeckTagAssignmentRepository:
    """Repository for DeckTagAssignment."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import DeckTagAssignment
        return DeckTagAssignment.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import DeckTagAssignment
        return DeckTagAssignment.objects.all()
