"""
Repository layer for the Cards BC bounded context.
Abstracts data access from domain logic.
"""

from sqlalchemy.orm import Session

from .models import Card, CardSet, CardRuling, CardAbility, Deck, DeckCard, DeckSideboardCard, DeckTag, DeckTagAssignment


class CardRepository:
    """Repository for Card."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> Card | None:
        return db.query(Card).filter(Card.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[Card]:
        return db.query(Card).all()


class CardSetRepository:
    """Repository for CardSet."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> CardSet | None:
        return db.query(CardSet).filter(CardSet.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[CardSet]:
        return db.query(CardSet).all()


class CardRulingRepository:
    """Repository for CardRuling."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> CardRuling | None:
        return db.query(CardRuling).filter(CardRuling.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[CardRuling]:
        return db.query(CardRuling).all()


class CardAbilityRepository:
    """Repository for CardAbility."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> CardAbility | None:
        return db.query(CardAbility).filter(CardAbility.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[CardAbility]:
        return db.query(CardAbility).all()


class DeckRepository:
    """Repository for Deck."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> Deck | None:
        return db.query(Deck).filter(Deck.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[Deck]:
        return db.query(Deck).all()


class DeckCardRepository:
    """Repository for DeckCard."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> DeckCard | None:
        return db.query(DeckCard).filter(DeckCard.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[DeckCard]:
        return db.query(DeckCard).all()


class DeckSideboardCardRepository:
    """Repository for DeckSideboardCard."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> DeckSideboardCard | None:
        return db.query(DeckSideboardCard).filter(DeckSideboardCard.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[DeckSideboardCard]:
        return db.query(DeckSideboardCard).all()


class DeckTagRepository:
    """Repository for DeckTag."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> DeckTag | None:
        return db.query(DeckTag).filter(DeckTag.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[DeckTag]:
        return db.query(DeckTag).all()


class DeckTagAssignmentRepository:
    """Repository for DeckTagAssignment."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> DeckTagAssignment | None:
        return db.query(DeckTagAssignment).filter(DeckTagAssignment.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[DeckTagAssignment]:
        return db.query(DeckTagAssignment).all()
