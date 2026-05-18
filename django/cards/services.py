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

    @staticmethod
    def apply_rarity_bonus(id, multiplier):
        from .models import Card
        instance = Card.objects.get(pk=id)
        result = instance.apply_rarity_bonus(multiplier)
        instance.save()
        return result

    @staticmethod
    def is_legal_in_format(id):
        from .models import Card
        instance = Card.objects.get(pk=id)
        result = instance.is_legal_in_format(format)
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

    @staticmethod
    def is_legal_in_standard(id):
        from .models import CardSet
        instance = CardSet.objects.get(pk=id)
        result = instance.is_legal_in_standard()
        instance.save()
        return result

    @staticmethod
    def is_legal_in_format(id):
        from .models import CardSet
        instance = CardSet.objects.get(pk=id)
        result = instance.is_legal_in_format(format)
        instance.save()
        return result

    @staticmethod
    def card_count_by_rarity(id):
        from .models import CardSet
        instance = CardSet.objects.get(pk=id)
        result = instance.card_count_by_rarity(rarity)
        instance.save()
        return result

    @staticmethod
    def rotate_out(id):
        from .models import CardSet
        instance = CardSet.objects.get(pk=id)
        instance.rotate_out()
        instance.save()


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

    @staticmethod
    def is_current(id):
        from .models import CardRuling
        instance = CardRuling.objects.get(pk=id)
        result = instance.is_current()
        instance.save()
        return result

    @staticmethod
    def supersedes_previous(id):
        from .models import CardRuling
        instance = CardRuling.objects.get(pk=id)
        result = instance.supersedes_previous()
        instance.save()
        return result


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

    @staticmethod
    def is_usable_at(id):
        from .models import CardAbility
        instance = CardAbility.objects.get(pk=id)
        result = instance.is_usable_at(timing)
        instance.save()
        return result

    @staticmethod
    def describe(id):
        from .models import CardAbility
        instance = CardAbility.objects.get(pk=id)
        result = instance.describe()
        instance.save()
        return result


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
    def add_card(id, card_id, quantity):
        from .models import Deck
        instance = Deck.objects.get(pk=id)
        instance.add_card(card_id, quantity)
        instance.save()

    @staticmethod
    def remove_card(id, card_id):
        from .models import Deck
        instance = Deck.objects.get(pk=id)
        instance.remove_card(card_id)
        instance.save()

    @staticmethod
    def win_rate(id):
        from .models import Deck
        instance = Deck.objects.get(pk=id)
        result = instance.win_rate()
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

    @staticmethod
    def increment(id, amount):
        from .models import DeckCard
        instance = DeckCard.objects.get(pk=id)
        instance.increment(amount)
        instance.save()

    @staticmethod
    def decrement(id, amount):
        from .models import DeckCard
        instance = DeckCard.objects.get(pk=id)
        instance.decrement(amount)
        instance.save()


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

    @staticmethod
    def increment(id, amount):
        from .models import DeckSideboardCard
        instance = DeckSideboardCard.objects.get(pk=id)
        instance.increment(amount)
        instance.save()

    @staticmethod
    def decrement(id, amount):
        from .models import DeckSideboardCard
        instance = DeckSideboardCard.objects.get(pk=id)
        instance.decrement(amount)
        instance.save()


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
    def rename(id, new_name):
        from .models import DeckTag
        instance = DeckTag.objects.get(pk=id)
        instance.rename(new_name)
        instance.save()

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
