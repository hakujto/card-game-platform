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
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class CardSetService:
    """Domain service for CardSet aggregate."""

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class CardRulingService:
    """Domain service for CardRuling aggregate."""

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class CardAbilityService:
    """Domain service for CardAbility aggregate."""

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
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class DeckSideboardCardService:
    """Domain service for DeckSideboardCard aggregate."""

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class DeckTagService:
    """Domain service for DeckTag aggregate."""

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
