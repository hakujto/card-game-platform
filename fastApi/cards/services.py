"""
Domain services for the Cards BC bounded context.
Place business logic that does not belong to a single model here.
"""

from sqlalchemy.orm import Session

from .models import Card, CardSet, CardRuling, CardAbility, Deck, DeckCard, DeckSideboardCard, DeckTag, DeckTagAssignment


class CardService:
    """Domain service for Card aggregate."""

    @staticmethod
    def ban(db: Session, pk: int):
        obj = db.query(Card).filter(Card.id == pk).first()
        if obj is None:
            raise ValueError("Card not found: " + str(pk))
        obj.ban()
        db.add(obj)
        db.commit()

    @staticmethod
    def unban(db: Session, pk: int):
        obj = db.query(Card).filter(Card.id == pk).first()
        if obj is None:
            raise ValueError("Card not found: " + str(pk))
        obj.unban()
        db.add(obj)
        db.commit()

    @staticmethod
    def restrict(db: Session, pk: int):
        obj = db.query(Card).filter(Card.id == pk).first()
        if obj is None:
            raise ValueError("Card not found: " + str(pk))
        obj.restrict()
        db.add(obj)
        db.commit()

    @staticmethod
    def unrestrict(db: Session, pk: int):
        obj = db.query(Card).filter(Card.id == pk).first()
        if obj is None:
            raise ValueError("Card not found: " + str(pk))
        obj.unrestrict()
        db.add(obj)
        db.commit()

    @staticmethod
    def calculate_value(db: Session, pk: int) -> float:
        obj = db.query(Card).filter(Card.id == pk).first()
        if obj is None:
            raise ValueError("Card not found: " + str(pk))
        result = obj.calculate_value()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def apply_rarity_bonus(db: Session, pk: int, multiplier: int) -> float:
        obj = db.query(Card).filter(Card.id == pk).first()
        if obj is None:
            raise ValueError("Card not found: " + str(pk))
        result = obj.apply_rarity_bonus(multiplier)
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def is_legal_in_format(db: Session, pk: int, format: str) -> bool:
        obj = db.query(Card).filter(Card.id == pk).first()
        if obj is None:
            raise ValueError("Card not found: " + str(pk))
        result = obj.is_legal_in_format(format)
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class CardSetService:
    """Domain service for CardSet aggregate."""

    @staticmethod
    def is_legal_in_standard(db: Session, pk: int) -> bool:
        obj = db.query(CardSet).filter(CardSet.id == pk).first()
        if obj is None:
            raise ValueError("CardSet not found: " + str(pk))
        result = obj.is_legal_in_standard()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def is_legal_in_format(db: Session, pk: int, format: str) -> bool:
        obj = db.query(CardSet).filter(CardSet.id == pk).first()
        if obj is None:
            raise ValueError("CardSet not found: " + str(pk))
        result = obj.is_legal_in_format(format)
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def card_count_by_rarity(db: Session, pk: int, rarity: str) -> int:
        obj = db.query(CardSet).filter(CardSet.id == pk).first()
        if obj is None:
            raise ValueError("CardSet not found: " + str(pk))
        result = obj.card_count_by_rarity(rarity)
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def rotate_out(db: Session, pk: int):
        obj = db.query(CardSet).filter(CardSet.id == pk).first()
        if obj is None:
            raise ValueError("CardSet not found: " + str(pk))
        obj.rotate_out()
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class CardRulingService:
    """Domain service for CardRuling aggregate."""

    @staticmethod
    def is_current(db: Session, pk: int) -> bool:
        obj = db.query(CardRuling).filter(CardRuling.id == pk).first()
        if obj is None:
            raise ValueError("CardRuling not found: " + str(pk))
        result = obj.is_current()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def supersedes_previous(db: Session, pk: int) -> bool:
        obj = db.query(CardRuling).filter(CardRuling.id == pk).first()
        if obj is None:
            raise ValueError("CardRuling not found: " + str(pk))
        result = obj.supersedes_previous()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class CardAbilityService:
    """Domain service for CardAbility aggregate."""

    @staticmethod
    def is_usable_at(db: Session, pk: int, timing: str) -> bool:
        obj = db.query(CardAbility).filter(CardAbility.id == pk).first()
        if obj is None:
            raise ValueError("CardAbility not found: " + str(pk))
        result = obj.is_usable_at(timing)
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def describe(db: Session, pk: int) -> str:
        obj = db.query(CardAbility).filter(CardAbility.id == pk).first()
        if obj is None:
            raise ValueError("CardAbility not found: " + str(pk))
        result = obj.describe()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class DeckService:
    """Domain service for Deck aggregate."""

    @staticmethod
    def validate_size(db: Session, pk: int) -> bool:
        obj = db.query(Deck).filter(Deck.id == pk).first()
        if obj is None:
            raise ValueError("Deck not found: " + str(pk))
        result = obj.validate_size()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def add_card(db: Session, pk: int, card_id: int, quantity: int):
        obj = db.query(Deck).filter(Deck.id == pk).first()
        if obj is None:
            raise ValueError("Deck not found: " + str(pk))
        obj.add_card(card_id, quantity)
        db.add(obj)
        db.commit()

    @staticmethod
    def remove_card(db: Session, pk: int, card_id: int):
        obj = db.query(Deck).filter(Deck.id == pk).first()
        if obj is None:
            raise ValueError("Deck not found: " + str(pk))
        obj.remove_card(card_id)
        db.add(obj)
        db.commit()

    @staticmethod
    def win_rate(db: Session, pk: int) -> float:
        obj = db.query(Deck).filter(Deck.id == pk).first()
        if obj is None:
            raise ValueError("Deck not found: " + str(pk))
        result = obj.win_rate()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def clone(db: Session, pk: int) -> None:
        obj = db.query(Deck).filter(Deck.id == pk).first()
        if obj is None:
            raise ValueError("Deck not found: " + str(pk))
        result = obj.clone()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def publish(db: Session, pk: int):
        obj = db.query(Deck).filter(Deck.id == pk).first()
        if obj is None:
            raise ValueError("Deck not found: " + str(pk))
        obj.publish()
        db.add(obj)
        db.commit()

    @staticmethod
    def unpublish(db: Session, pk: int):
        obj = db.query(Deck).filter(Deck.id == pk).first()
        if obj is None:
            raise ValueError("Deck not found: " + str(pk))
        obj.unpublish()
        db.add(obj)
        db.commit()

    @staticmethod
    def certify_tournament_legal(db: Session, pk: int) -> bool:
        obj = db.query(Deck).filter(Deck.id == pk).first()
        if obj is None:
            raise ValueError("Deck not found: " + str(pk))
        result = obj.certify_tournament_legal()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class DeckCardService:
    """Domain service for DeckCard aggregate."""

    @staticmethod
    def increment(db: Session, pk: int, amount: int):
        obj = db.query(DeckCard).filter(DeckCard.id == pk).first()
        if obj is None:
            raise ValueError("DeckCard not found: " + str(pk))
        obj.increment(amount)
        db.add(obj)
        db.commit()

    @staticmethod
    def decrement(db: Session, pk: int, amount: int):
        obj = db.query(DeckCard).filter(DeckCard.id == pk).first()
        if obj is None:
            raise ValueError("DeckCard not found: " + str(pk))
        obj.decrement(amount)
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class DeckSideboardCardService:
    """Domain service for DeckSideboardCard aggregate."""

    @staticmethod
    def increment(db: Session, pk: int, amount: int):
        obj = db.query(DeckSideboardCard).filter(DeckSideboardCard.id == pk).first()
        if obj is None:
            raise ValueError("DeckSideboardCard not found: " + str(pk))
        obj.increment(amount)
        db.add(obj)
        db.commit()

    @staticmethod
    def decrement(db: Session, pk: int, amount: int):
        obj = db.query(DeckSideboardCard).filter(DeckSideboardCard.id == pk).first()
        if obj is None:
            raise ValueError("DeckSideboardCard not found: " + str(pk))
        obj.decrement(amount)
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class DeckTagService:
    """Domain service for DeckTag aggregate."""

    @staticmethod
    def rename(db: Session, pk: int, new_name: str):
        obj = db.query(DeckTag).filter(DeckTag.id == pk).first()
        if obj is None:
            raise ValueError("DeckTag not found: " + str(pk))
        obj.rename(new_name)
        db.add(obj)
        db.commit()

    @staticmethod
    def merge_into(db: Session, pk: int, target_tag_id: int):
        obj = db.query(DeckTag).filter(DeckTag.id == pk).first()
        if obj is None:
            raise ValueError("DeckTag not found: " + str(pk))
        obj.merge_into(target_tag_id)
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class DeckTagAssignmentService:
    """Domain service for DeckTagAssignment aggregate."""

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError
