from typing import Sequence

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db import get_db
from .models import Card, CardSet, CardRuling, CardAbility, Deck, DeckCard, DeckSideboardCard, DeckTag, DeckTagAssignment
from .schemas import CardCreate, CardUpdate, CardRead, CardSetCreate, CardSetUpdate, CardSetRead, CardRulingCreate, CardRulingUpdate, CardRulingRead, CardAbilityCreate, CardAbilityUpdate, CardAbilityRead, DeckCreate, DeckUpdate, DeckRead, DeckCardCreate, DeckCardUpdate, DeckCardRead, DeckSideboardCardCreate, DeckSideboardCardUpdate, DeckSideboardCardRead, DeckTagCreate, DeckTagUpdate, DeckTagRead, DeckTagAssignmentCreate, DeckTagAssignmentUpdate, DeckTagAssignmentRead

router_card = APIRouter(prefix="/api/cards", tags=["Card"])

@router_card.get("", response_model=list[CardRead])
def list_cards(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Card]:
    return db.query(Card).offset(skip).limit(limit).all()

@router_card.post("", response_model=CardRead, status_code=status.HTTP_201_CREATED)
def create_card(data: CardCreate, db: Session = Depends(get_db)) -> Card:
    obj = Card(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_card.get("/{item_id}", response_model=CardRead)
def get_card(item_id: int, db: Session = Depends(get_db)) -> Card:
    obj = db.query(Card).filter(Card.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Card not found")
    return obj

@router_card.put("/{item_id}", response_model=CardRead)
def update_card(item_id: int, data: CardUpdate, db: Session = Depends(get_db)) -> Card:
    obj = db.query(Card).filter(Card.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Card not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_card.patch("/{item_id}", response_model=CardRead)
def patch_card(item_id: int, data: CardUpdate, db: Session = Depends(get_db)) -> Card:
    return update_card(item_id, data, db)

@router_card.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_card(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(Card).filter(Card.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Card not found")
    db.delete(obj)
    db.commit()

router_card_set = APIRouter(prefix="/api/card_sets", tags=["Card Set"])

@router_card_set.get("", response_model=list[CardSetRead])
def list_card_sets(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[CardSet]:
    return db.query(CardSet).offset(skip).limit(limit).all()

@router_card_set.post("", response_model=CardSetRead, status_code=status.HTTP_201_CREATED)
def create_card_set(data: CardSetCreate, db: Session = Depends(get_db)) -> CardSet:
    obj = CardSet(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_card_set.get("/{item_id}", response_model=CardSetRead)
def get_card_set(item_id: int, db: Session = Depends(get_db)) -> CardSet:
    obj = db.query(CardSet).filter(CardSet.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CardSet not found")
    return obj

@router_card_set.put("/{item_id}", response_model=CardSetRead)
def update_card_set(item_id: int, data: CardSetUpdate, db: Session = Depends(get_db)) -> CardSet:
    obj = db.query(CardSet).filter(CardSet.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CardSet not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_card_set.patch("/{item_id}", response_model=CardSetRead)
def patch_card_set(item_id: int, data: CardSetUpdate, db: Session = Depends(get_db)) -> CardSet:
    return update_card_set(item_id, data, db)

@router_card_set.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_card_set(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(CardSet).filter(CardSet.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CardSet not found")
    db.delete(obj)
    db.commit()

router_card_ruling = APIRouter(prefix="/api/card_rulings", tags=["Card Ruling"])

@router_card_ruling.get("", response_model=list[CardRulingRead])
def list_card_rulings(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[CardRuling]:
    return db.query(CardRuling).offset(skip).limit(limit).all()

@router_card_ruling.post("", response_model=CardRulingRead, status_code=status.HTTP_201_CREATED)
def create_card_ruling(data: CardRulingCreate, db: Session = Depends(get_db)) -> CardRuling:
    obj = CardRuling(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_card_ruling.get("/{item_id}", response_model=CardRulingRead)
def get_card_ruling(item_id: int, db: Session = Depends(get_db)) -> CardRuling:
    obj = db.query(CardRuling).filter(CardRuling.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CardRuling not found")
    return obj

@router_card_ruling.put("/{item_id}", response_model=CardRulingRead)
def update_card_ruling(item_id: int, data: CardRulingUpdate, db: Session = Depends(get_db)) -> CardRuling:
    obj = db.query(CardRuling).filter(CardRuling.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CardRuling not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_card_ruling.patch("/{item_id}", response_model=CardRulingRead)
def patch_card_ruling(item_id: int, data: CardRulingUpdate, db: Session = Depends(get_db)) -> CardRuling:
    return update_card_ruling(item_id, data, db)

@router_card_ruling.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_card_ruling(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(CardRuling).filter(CardRuling.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CardRuling not found")
    db.delete(obj)
    db.commit()

router_card_ability = APIRouter(prefix="/api/card_abilities", tags=["Card Ability"])

@router_card_ability.get("", response_model=list[CardAbilityRead])
def list_card_abilities(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[CardAbility]:
    return db.query(CardAbility).offset(skip).limit(limit).all()

@router_card_ability.post("", response_model=CardAbilityRead, status_code=status.HTTP_201_CREATED)
def create_card_ability(data: CardAbilityCreate, db: Session = Depends(get_db)) -> CardAbility:
    obj = CardAbility(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_card_ability.get("/{item_id}", response_model=CardAbilityRead)
def get_card_ability(item_id: int, db: Session = Depends(get_db)) -> CardAbility:
    obj = db.query(CardAbility).filter(CardAbility.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CardAbility not found")
    return obj

@router_card_ability.put("/{item_id}", response_model=CardAbilityRead)
def update_card_ability(item_id: int, data: CardAbilityUpdate, db: Session = Depends(get_db)) -> CardAbility:
    obj = db.query(CardAbility).filter(CardAbility.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CardAbility not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_card_ability.patch("/{item_id}", response_model=CardAbilityRead)
def patch_card_ability(item_id: int, data: CardAbilityUpdate, db: Session = Depends(get_db)) -> CardAbility:
    return update_card_ability(item_id, data, db)

@router_card_ability.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_card_ability(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(CardAbility).filter(CardAbility.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CardAbility not found")
    db.delete(obj)
    db.commit()

router_deck = APIRouter(prefix="/api/decks", tags=["Deck"])

@router_deck.get("", response_model=list[DeckRead])
def list_decks(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Deck]:
    return db.query(Deck).offset(skip).limit(limit).all()

@router_deck.post("", response_model=DeckRead, status_code=status.HTTP_201_CREATED)
def create_deck(data: DeckCreate, db: Session = Depends(get_db)) -> Deck:
    obj = Deck(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_deck.get("/{item_id}", response_model=DeckRead)
def get_deck(item_id: int, db: Session = Depends(get_db)) -> Deck:
    obj = db.query(Deck).filter(Deck.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Deck not found")
    return obj

@router_deck.put("/{item_id}", response_model=DeckRead)
def update_deck(item_id: int, data: DeckUpdate, db: Session = Depends(get_db)) -> Deck:
    obj = db.query(Deck).filter(Deck.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Deck not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_deck.patch("/{item_id}", response_model=DeckRead)
def patch_deck(item_id: int, data: DeckUpdate, db: Session = Depends(get_db)) -> Deck:
    return update_deck(item_id, data, db)

@router_deck.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_deck(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(Deck).filter(Deck.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Deck not found")
    db.delete(obj)
    db.commit()

router_deck_card = APIRouter(prefix="/api/deck_cards", tags=["Deck Card"])

@router_deck_card.get("", response_model=list[DeckCardRead])
def list_deck_cards(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[DeckCard]:
    return db.query(DeckCard).offset(skip).limit(limit).all()

@router_deck_card.post("", response_model=DeckCardRead, status_code=status.HTTP_201_CREATED)
def create_deck_card(data: DeckCardCreate, db: Session = Depends(get_db)) -> DeckCard:
    obj = DeckCard(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_deck_card.get("/{item_id}", response_model=DeckCardRead)
def get_deck_card(item_id: int, db: Session = Depends(get_db)) -> DeckCard:
    obj = db.query(DeckCard).filter(DeckCard.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DeckCard not found")
    return obj

@router_deck_card.put("/{item_id}", response_model=DeckCardRead)
def update_deck_card(item_id: int, data: DeckCardUpdate, db: Session = Depends(get_db)) -> DeckCard:
    obj = db.query(DeckCard).filter(DeckCard.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DeckCard not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_deck_card.patch("/{item_id}", response_model=DeckCardRead)
def patch_deck_card(item_id: int, data: DeckCardUpdate, db: Session = Depends(get_db)) -> DeckCard:
    return update_deck_card(item_id, data, db)

@router_deck_card.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_deck_card(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(DeckCard).filter(DeckCard.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DeckCard not found")
    db.delete(obj)
    db.commit()

router_deck_sideboard_card = APIRouter(prefix="/api/deck_sideboard_cards", tags=["Deck Sideboard Card"])

@router_deck_sideboard_card.get("", response_model=list[DeckSideboardCardRead])
def list_deck_sideboard_cards(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[DeckSideboardCard]:
    return db.query(DeckSideboardCard).offset(skip).limit(limit).all()

@router_deck_sideboard_card.post("", response_model=DeckSideboardCardRead, status_code=status.HTTP_201_CREATED)
def create_deck_sideboard_card(data: DeckSideboardCardCreate, db: Session = Depends(get_db)) -> DeckSideboardCard:
    obj = DeckSideboardCard(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_deck_sideboard_card.get("/{item_id}", response_model=DeckSideboardCardRead)
def get_deck_sideboard_card(item_id: int, db: Session = Depends(get_db)) -> DeckSideboardCard:
    obj = db.query(DeckSideboardCard).filter(DeckSideboardCard.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DeckSideboardCard not found")
    return obj

@router_deck_sideboard_card.put("/{item_id}", response_model=DeckSideboardCardRead)
def update_deck_sideboard_card(item_id: int, data: DeckSideboardCardUpdate, db: Session = Depends(get_db)) -> DeckSideboardCard:
    obj = db.query(DeckSideboardCard).filter(DeckSideboardCard.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DeckSideboardCard not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_deck_sideboard_card.patch("/{item_id}", response_model=DeckSideboardCardRead)
def patch_deck_sideboard_card(item_id: int, data: DeckSideboardCardUpdate, db: Session = Depends(get_db)) -> DeckSideboardCard:
    return update_deck_sideboard_card(item_id, data, db)

@router_deck_sideboard_card.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_deck_sideboard_card(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(DeckSideboardCard).filter(DeckSideboardCard.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DeckSideboardCard not found")
    db.delete(obj)
    db.commit()

router_deck_tag = APIRouter(prefix="/api/deck_tags", tags=["Deck Tag"])

@router_deck_tag.get("", response_model=list[DeckTagRead])
def list_deck_tags(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[DeckTag]:
    return db.query(DeckTag).offset(skip).limit(limit).all()

@router_deck_tag.post("", response_model=DeckTagRead, status_code=status.HTTP_201_CREATED)
def create_deck_tag(data: DeckTagCreate, db: Session = Depends(get_db)) -> DeckTag:
    obj = DeckTag(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_deck_tag.get("/{item_id}", response_model=DeckTagRead)
def get_deck_tag(item_id: int, db: Session = Depends(get_db)) -> DeckTag:
    obj = db.query(DeckTag).filter(DeckTag.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DeckTag not found")
    return obj

@router_deck_tag.put("/{item_id}", response_model=DeckTagRead)
def update_deck_tag(item_id: int, data: DeckTagUpdate, db: Session = Depends(get_db)) -> DeckTag:
    obj = db.query(DeckTag).filter(DeckTag.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DeckTag not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_deck_tag.patch("/{item_id}", response_model=DeckTagRead)
def patch_deck_tag(item_id: int, data: DeckTagUpdate, db: Session = Depends(get_db)) -> DeckTag:
    return update_deck_tag(item_id, data, db)

@router_deck_tag.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_deck_tag(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(DeckTag).filter(DeckTag.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DeckTag not found")
    db.delete(obj)
    db.commit()

router_deck_tag_assignment = APIRouter(prefix="/api/deck_tag_assignments", tags=["Deck Tag Assignment"])

@router_deck_tag_assignment.get("", response_model=list[DeckTagAssignmentRead])
def list_deck_tag_assignments(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[DeckTagAssignment]:
    return db.query(DeckTagAssignment).offset(skip).limit(limit).all()

@router_deck_tag_assignment.post("", response_model=DeckTagAssignmentRead, status_code=status.HTTP_201_CREATED)
def create_deck_tag_assignment(data: DeckTagAssignmentCreate, db: Session = Depends(get_db)) -> DeckTagAssignment:
    obj = DeckTagAssignment(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_deck_tag_assignment.get("/{item_id}", response_model=DeckTagAssignmentRead)
def get_deck_tag_assignment(item_id: int, db: Session = Depends(get_db)) -> DeckTagAssignment:
    obj = db.query(DeckTagAssignment).filter(DeckTagAssignment.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DeckTagAssignment not found")
    return obj

@router_deck_tag_assignment.put("/{item_id}", response_model=DeckTagAssignmentRead)
def update_deck_tag_assignment(item_id: int, data: DeckTagAssignmentUpdate, db: Session = Depends(get_db)) -> DeckTagAssignment:
    obj = db.query(DeckTagAssignment).filter(DeckTagAssignment.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DeckTagAssignment not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_deck_tag_assignment.patch("/{item_id}", response_model=DeckTagAssignmentRead)
def patch_deck_tag_assignment(item_id: int, data: DeckTagAssignmentUpdate, db: Session = Depends(get_db)) -> DeckTagAssignment:
    return update_deck_tag_assignment(item_id, data, db)

@router_deck_tag_assignment.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_deck_tag_assignment(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(DeckTagAssignment).filter(DeckTagAssignment.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DeckTagAssignment not found")
    db.delete(obj)
    db.commit()
