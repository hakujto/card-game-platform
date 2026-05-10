from __future__ import annotations

from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict

class CardBase(BaseModel):
    name: str
    card_type: str
    rarity: str
    mana_cost: int
    mana_colors: str
    attack: int | None = None
    defense: int | None = None
    loyalty: int | None = None
    description: str
    flavor_text: str | None = None
    image_url: str | None = None
    artist_name: str | None = None
    legal_formats: str
    is_banned: bool
    is_restricted: bool
    power_level: int
    set_id: int
    rulings_id: int | None = None
    abilities_id: int | None = None


class CardCreate(CardBase):
    pass


class CardUpdate(BaseModel):
    name: str | None = None
    card_type: str | None = None
    rarity: str | None = None
    mana_cost: int | None = None
    mana_colors: str | None = None
    attack: int | None = None
    defense: int | None = None
    loyalty: int | None = None
    description: str | None = None
    flavor_text: str | None = None
    image_url: str | None = None
    artist_name: str | None = None
    legal_formats: str | None = None
    is_banned: bool | None = None
    is_restricted: bool | None = None
    power_level: int | None = None
    set_id: int | None = None
    rulings_id: int | None = None
    abilities_id: int | None = None


class CardRead(CardBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class CardSetBase(BaseModel):
    name: str
    code: str
    release_date: date
    set_type: str
    total_cards: int
    description: str | None = None
    logo_url: str | None = None


class CardSetCreate(CardSetBase):
    pass


class CardSetUpdate(BaseModel):
    name: str | None = None
    code: str | None = None
    release_date: date | None = None
    set_type: str | None = None
    total_cards: int | None = None
    description: str | None = None
    logo_url: str | None = None


class CardSetRead(CardSetBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class CardRulingBase(BaseModel):
    ruling_text: str
    published_at: date
    source: str
    card_id: int


class CardRulingCreate(CardRulingBase):
    pass


class CardRulingUpdate(BaseModel):
    ruling_text: str | None = None
    published_at: date | None = None
    source: str | None = None
    card_id: int | None = None


class CardRulingRead(CardRulingBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class CardAbilityBase(BaseModel):
    ability_type: str
    keyword: str | None = None
    ability_text: str
    timing: str | None = None
    card_id: int


class CardAbilityCreate(CardAbilityBase):
    pass


class CardAbilityUpdate(BaseModel):
    ability_type: str | None = None
    keyword: str | None = None
    ability_text: str | None = None
    timing: str | None = None
    card_id: int | None = None


class CardAbilityRead(CardAbilityBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class DeckBase(BaseModel):
    name: str
    description: str | None = None
    format: str
    is_public: bool
    is_tournament_legal: bool
    archetype: str | None = None
    wins: int
    losses: int
    created_at: datetime
    updated_at: datetime
    player_id: int
    cards_ids: list[int] = []
    sideboard_cards_ids: list[int] = []
    tags_ids: list[int] = []


class DeckCreate(DeckBase):
    pass


class DeckUpdate(BaseModel):
    name: str | None = None
    description: str | None = None
    format: str | None = None
    is_public: bool | None = None
    is_tournament_legal: bool | None = None
    archetype: str | None = None
    wins: int | None = None
    losses: int | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None
    player_id: int | None = None
    cards_ids: list[int] | None = None
    sideboard_cards_ids: list[int] | None = None
    tags_ids: list[int] | None = None


class DeckRead(DeckBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class DeckCardBase(BaseModel):
    quantity: int
    is_commander: bool
    deck_id: int
    card_id: int


class DeckCardCreate(DeckCardBase):
    pass


class DeckCardUpdate(BaseModel):
    quantity: int | None = None
    is_commander: bool | None = None
    deck_id: int | None = None
    card_id: int | None = None


class DeckCardRead(DeckCardBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class DeckSideboardCardBase(BaseModel):
    quantity: int
    deck_id: int
    card_id: int


class DeckSideboardCardCreate(DeckSideboardCardBase):
    pass


class DeckSideboardCardUpdate(BaseModel):
    quantity: int | None = None
    deck_id: int | None = None
    card_id: int | None = None


class DeckSideboardCardRead(DeckSideboardCardBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class DeckTagBase(BaseModel):
    name: str
    color: str | None = None


class DeckTagCreate(DeckTagBase):
    pass


class DeckTagUpdate(BaseModel):
    name: str | None = None
    color: str | None = None


class DeckTagRead(DeckTagBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class DeckTagAssignmentBase(BaseModel):
    deck_id: int
    tag_id: int


class DeckTagAssignmentCreate(DeckTagAssignmentBase):
    pass


class DeckTagAssignmentUpdate(BaseModel):
    deck_id: int | None = None
    tag_id: int | None = None


class DeckTagAssignmentRead(DeckTagAssignmentBase):
    id: int
    model_config = ConfigDict(from_attributes=True)
