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

    @staticmethod
    def ban(id):
        from .models import Card
        instance = Card.objects.get(pk=id)
        instance.ban()
        instance.save()

    @staticmethod
    def unban(id):
        from .models import Card
        instance = Card.objects.get(pk=id)
        instance.unban()
        instance.save()

    @staticmethod
    def restrict(id):
        from .models import Card
        instance = Card.objects.get(pk=id)
        instance.restrict()
        instance.save()

    @staticmethod
    def unrestrict(id):
        from .models import Card
        instance = Card.objects.get(pk=id)
        instance.unrestrict()
        instance.save()

    @staticmethod
    def calculate_value(id):
        from .models import Card
        instance = Card.objects.get(pk=id)
        result = instance.calculate_value()
        instance.save()
        return result


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

    @staticmethod
    def validate_size(id):
        from .models import Deck
        instance = Deck.objects.get(pk=id)
        result = instance.validate_size()
        instance.save()
        return result

    @staticmethod
    def clone(id):
        from .models import Deck
        instance = Deck.objects.get(pk=id)
        result = instance.clone()
        instance.save()
        return result

    @staticmethod
    def publish(id):
        from .models import Deck
        instance = Deck.objects.get(pk=id)
        instance.publish()
        instance.save()

    @staticmethod
    def unpublish(id):
        from .models import Deck
        instance = Deck.objects.get(pk=id)
        instance.unpublish()
        instance.save()

    @staticmethod
    def certify_tournament_legal(id):
        from .models import Deck
        instance = Deck.objects.get(pk=id)
        result = instance.certify_tournament_legal()
        instance.save()
        return result


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

    @staticmethod
    def merge_into(id, target_tag_id):
        from .models import DeckTag
        instance = DeckTag.objects.get(pk=id)
        instance.merge_into(target_tag_id)
        instance.save()


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
