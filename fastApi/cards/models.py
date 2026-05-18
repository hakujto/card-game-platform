from __future__ import annotations

from sqlalchemy import (
    Boolean, Column, Date, DateTime, Float, ForeignKey, Integer,
    JSON, Numeric, SmallInteger, String, Table, Text,
)
from sqlalchemy.orm import relationship

from app.db import Base

deck_cards_assoc = Table(
    "deck_cards_m2m",
    Base.metadata,
    Column("deck_id", Integer, ForeignKey("deck.id"), primary_key=True),
    Column("card_id", Integer, ForeignKey("card.id"), primary_key=True),
)

deck_sideboard_cards_assoc = Table(
    "deck_sideboard_cards_m2m",
    Base.metadata,
    Column("deck_id", Integer, ForeignKey("deck.id"), primary_key=True),
    Column("card_id", Integer, ForeignKey("card.id"), primary_key=True),
)

deck_tags_assoc = Table(
    "deck_tags_m2m",
    Base.metadata,
    Column("deck_id", Integer, ForeignKey("deck.id"), primary_key=True),
    Column("deck_tag_id", Integer, ForeignKey("deck_tag.id"), primary_key=True),
)

from typing import Literal

CardCardTypeType = Literal["Creature", "Spell", "Land", "Artifact", "Enchantment", "Planeswalker"]
CardRarityType = Literal["Common", "Uncommon", "Rare", "MythicRare", "Legendary"]
CardManaColorsType = Literal["White", "Blue", "Black", "Red", "Green", "Colorless"]
CardLegalFormatsType = Literal["Standard", "Extended", "Legacy", "Vintage", "Commander", "Draft"]

class Card(Base):
    __tablename__ = "card"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200))
    card_type = Column(String(20), default="Creature")
    rarity = Column(String(20), default="Common")
    mana_cost = Column(Integer, default="0")
    mana_colors = Column(String(20))
    attack = Column(Integer, nullable=True)
    defense = Column(Integer, nullable=True)
    loyalty = Column(Integer, nullable=True)
    description = Column(Text)
    flavor_text = Column(Text, nullable=True)
    image_url = Column(String(200), nullable=True)
    artist_name = Column(String(100), nullable=True)
    legal_formats = Column(String(20))
    is_banned = Column(Boolean, default="false")
    is_restricted = Column(Boolean, default="false")
    power_level = Column(Integer, default="1")
    set_id = Column(Integer, ForeignKey("card_set.id"), nullable=False)
    set = relationship("CardSet", foreign_keys=[set_id])

    def ban(self):
        raise NotImplementedError("ban not implemented")

    def unban(self):
        raise NotImplementedError("unban not implemented")

    def restrict(self):
        raise NotImplementedError("restrict not implemented")

    def unrestrict(self):
        raise NotImplementedError("unrestrict not implemented")

    def calculate_value(self) -> float:
        raise NotImplementedError("calculate_value not implemented")

    def apply_rarity_bonus(self, multiplier: int) -> float:
        raise NotImplementedError("apply_rarity_bonus not implemented")

    def is_legal_in_format(self, format: str) -> bool:
        raise NotImplementedError("is_legal_in_format not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.mana_cost is None or (self.mana_cost >= 0 and self.mana_cost <= 20))):
            errors.append("mana_cost must be between 0 and 20")
        if not ((self.power_level is None or (self.power_level >= 1 and self.power_level <= 10))):
            errors.append("power_level must be between 1 and 10")
        if not (not ((self.is_banned is True and self.is_restricted is True))):
            errors.append("Card cannot be both banned and restricted at the same time")
        return errors

    def validate_implies(self) -> list[str]:
        errors = []
        if (self.card_type == "Creature") and not ((self.attack is not None and self.defense is not None)):
            errors.append("Creature card must have attack and defense")
        if (self.card_type == "Planeswalker") and not (self.loyalty is not None):
            errors.append("Planeswalker card must have loyalty")
        if (self.card_type != "Planeswalker") and not (self.loyalty is None):
            errors.append("Only Planeswalker cards can have loyalty")
        if (self.is_banned is True) and not (self.legal_formats == "message"):
            errors.append("banned_card_not_in_legal_formats")
        return errors
    def __repr__(self) -> str:
        return f"<Card id={{self.id}}>"


from typing import Literal

CardSetSetTypeType = Literal["Core", "Expansion", "Supplemental", "Masters", "Draft"]

class CardSet(Base):
    __tablename__ = "card_set"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200))
    code = Column(String(10))
    release_date = Column(Date)
    rotation_date = Column(Date, nullable=True)
    set_type = Column(String(20), default="Expansion")
    total_cards = Column(Integer)
    is_rotated = Column(Boolean, default="false")
    description = Column(Text, nullable=True)
    logo_url = Column(String(200), nullable=True)

    def is_legal_in_standard(self) -> bool:
        raise NotImplementedError("is_legal_in_standard not implemented")

    def is_legal_in_format(self, format: str) -> bool:
        raise NotImplementedError("is_legal_in_format not implemented")

    def card_count_by_rarity(self, rarity: str) -> int:
        raise NotImplementedError("card_count_by_rarity not implemented")

    def rotate_out(self):
        raise NotImplementedError("rotate_out not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.total_cards is None or self.total_cards > 0)):
            errors.append("Card set must have at least one card")
        return errors

    def validate_implies(self) -> list[str]:
        errors = []
        if (self.rotation_date is not None) and not ((self.rotation_date is None or (self.release_date is not None and self.rotation_date > self.release_date))):
            errors.append("Rotation date must be after release date")
        if (self.is_rotated is True) and not (self.rotation_date is not None):
            errors.append("Rotated set must have a rotation date")
        return errors
    def __repr__(self) -> str:
        return f"<CardSet id={{self.id}}>"


class CardRuling(Base):
    __tablename__ = "card_ruling"

    id = Column(Integer, primary_key=True, index=True)
    ruling_text = Column(Text)
    published_at = Column(Date)
    source = Column(String(200))
    card_id = Column(Integer, ForeignKey("card.id"), nullable=False)
    card = relationship("Card", foreign_keys=[card_id])

    def is_current(self) -> bool:
        raise NotImplementedError("is_current not implemented")

    def supersedes_previous(self) -> bool:
        raise NotImplementedError("supersedes_previous not implemented")

    def __repr__(self) -> str:
        return f"<CardRuling id={{self.id}}>"


from typing import Literal

CardAbilityAbilityTypeType = Literal["Keyword", "Activated", "Triggered", "Static"]
CardAbilityTimingType = Literal["Any", "Sorcery", "Instant", "Combat"]

class CardAbility(Base):
    __tablename__ = "card_ability"

    id = Column(Integer, primary_key=True, index=True)
    ability_type = Column(String(20), default="Keyword")
    keyword = Column(String(100), nullable=True)
    ability_text = Column(Text)
    timing = Column(String(20), nullable=True)
    card_id = Column(Integer, ForeignKey("card.id"), nullable=False)
    card = relationship("Card", foreign_keys=[card_id])

    def is_usable_at(self, timing: str) -> bool:
        raise NotImplementedError("is_usable_at not implemented")

    def describe(self) -> str:
        raise NotImplementedError("describe not implemented")


    def validate_implies(self) -> list[str]:
        errors = []
        if (self.ability_type == "Keyword") and not (self.keyword is not None):
            errors.append("Keyword ability must have a keyword name")
        return errors
    def __repr__(self) -> str:
        return f"<CardAbility id={{self.id}}>"


from typing import Literal

DeckFormatType = Literal["Standard", "Extended", "Legacy", "Vintage", "Commander", "Draft"]
DeckArchetypeType = Literal["Aggro", "Control", "Midrange", "Combo", "Prison", "Tempo"]

class Deck(Base):
    __tablename__ = "deck"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100))
    description = Column(Text, nullable=True)
    format = Column(String(20), default="Standard")
    is_public = Column(Boolean, default="false")
    is_tournament_legal = Column(Boolean, default="false")
    archetype = Column(String(20), nullable=True)
    wins = Column(Integer, default="0")
    losses = Column(Integer, default="0")
    draws = Column(Integer, default="0")
    created_at = Column(DateTime)
    updated_at = Column(DateTime)
    player_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    player = relationship("Player", foreign_keys=[player_id])
    cards = relationship("Card", secondary=deck_cards_assoc)
    sideboard_cards = relationship("Card", secondary=deck_sideboard_cards_assoc)
    tags = relationship("DeckTag", secondary=deck_tags_assoc)

    def validate_size(self) -> bool:
        raise NotImplementedError("validate_size not implemented")

    def add_card(self, card_id: int, quantity: int):
        raise NotImplementedError("add_card not implemented")

    def remove_card(self, card_id: int):
        raise NotImplementedError("remove_card not implemented")

    def win_rate(self) -> float:
        raise NotImplementedError("win_rate not implemented")

    def clone(self) -> None:
        raise NotImplementedError("clone not implemented")

    def publish(self):
        raise NotImplementedError("publish not implemented")

    def unpublish(self):
        raise NotImplementedError("unpublish not implemented")

    def certify_tournament_legal(self) -> bool:
        raise NotImplementedError("certify_tournament_legal not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.wins is None or self.wins >= 0)):
            errors.append("Deck wins count must not be negative")
        if not ((self.losses is None or self.losses >= 0)):
            errors.append("Deck losses count must not be negative")
        if not ((self.draws is None or self.draws >= 0)):
            errors.append("Deck draws count must not be negative")
        return errors

    def validate_implies(self) -> list[str]:
        errors = []
        if (self.is_tournament_legal is True) and not (self.is_public is True):
            errors.append("Tournament-legal deck must be made public")
        return errors
    def __repr__(self) -> str:
        return f"<Deck id={{self.id}}>"


class DeckCard(Base):
    __tablename__ = "deck_card"

    id = Column(Integer, primary_key=True, index=True)
    quantity = Column(Integer, default="1")
    is_commander = Column(Boolean, default="false")
    deck_id = Column(Integer, ForeignKey("deck.id"), nullable=False)
    deck = relationship("Deck", foreign_keys=[deck_id])
    card_id = Column(Integer, ForeignKey("card.id"), nullable=False)
    card = relationship("Card", foreign_keys=[card_id])

    def increment(self, amount: int):
        raise NotImplementedError("increment not implemented")

    def decrement(self, amount: int):
        raise NotImplementedError("decrement not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.quantity is None or (self.quantity >= 1 and self.quantity <= 4))):
            errors.append("A deck can contain between 1 and 4 copies of a card")
        return errors
    def __repr__(self) -> str:
        return f"<DeckCard id={{self.id}}>"


class DeckSideboardCard(Base):
    __tablename__ = "deck_sideboard_card"

    id = Column(Integer, primary_key=True, index=True)
    quantity = Column(Integer, default="1")
    deck_id = Column(Integer, ForeignKey("deck.id"), nullable=False)
    deck = relationship("Deck", foreign_keys=[deck_id])
    card_id = Column(Integer, ForeignKey("card.id"), nullable=False)
    card = relationship("Card", foreign_keys=[card_id])

    def increment(self, amount: int):
        raise NotImplementedError("increment not implemented")

    def decrement(self, amount: int):
        raise NotImplementedError("decrement not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.quantity is None or (self.quantity >= 1 and self.quantity <= 4))):
            errors.append("Sideboard card quantity must be between 1 and 4 copies")
        return errors
    def __repr__(self) -> str:
        return f"<DeckSideboardCard id={{self.id}}>"


class DeckTag(Base):
    __tablename__ = "deck_tag"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50))
    color = Column(String(7), nullable=True)

    def rename(self, new_name: str):
        raise NotImplementedError("rename not implemented")

    def merge_into(self, target_tag_id: int):
        raise NotImplementedError("merge_into not implemented")

    def __repr__(self) -> str:
        return f"<DeckTag id={{self.id}}>"


class DeckTagAssignment(Base):
    __tablename__ = "deck_tag_assignment"

    id = Column(Integer, primary_key=True, index=True)
    deck_id = Column(Integer, ForeignKey("deck.id"), nullable=False)
    deck = relationship("Deck", foreign_keys=[deck_id])
    tag_id = Column(Integer, ForeignKey("deck_tag.id"), nullable=False)
    tag = relationship("DeckTag", foreign_keys=[tag_id])
    def __repr__(self) -> str:
        return f"<DeckTagAssignment id={{self.id}}>"
