from typing import Sequence

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db import get_db
from .models import Player, PlayerSeasonStats, PlayerCollection, Friendship, Achievement, PlayerAchievement, CraftingRecipe, CraftingIngredient
from .schemas import PlayerCreate, PlayerUpdate, PlayerRead, PlayerSeasonStatsCreate, PlayerSeasonStatsUpdate, PlayerSeasonStatsRead, PlayerCollectionCreate, PlayerCollectionUpdate, PlayerCollectionRead, FriendshipCreate, FriendshipUpdate, FriendshipRead, AchievementCreate, AchievementUpdate, AchievementRead, PlayerAchievementCreate, PlayerAchievementUpdate, PlayerAchievementRead, CraftingRecipeCreate, CraftingRecipeUpdate, CraftingRecipeRead, CraftingIngredientCreate, CraftingIngredientUpdate, CraftingIngredientRead

def _validate_player(obj: Player) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_rules())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_player = APIRouter(prefix="/api/players", tags=["Player"])

@router_player.get("", response_model=list[PlayerRead])
def list_players(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Player]:
    return db.query(Player).offset(skip).limit(limit).all()

@router_player.post("", response_model=PlayerRead, status_code=status.HTTP_201_CREATED)
def create_player(data: PlayerCreate, db: Session = Depends(get_db)) -> Player:
    obj = Player(**data.model_dump(exclude_unset=True))
    _validate_player(obj)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_player.get("/{item_id}", response_model=PlayerRead)
def get_player(item_id: int, db: Session = Depends(get_db)) -> Player:
    obj = db.query(Player).filter(Player.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Player not found")
    return obj

@router_player.put("/{item_id}", response_model=PlayerRead)
def update_player(item_id: int, data: PlayerUpdate, db: Session = Depends(get_db)) -> Player:
    obj = db.query(Player).filter(Player.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Player not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    _validate_player(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_player.patch("/{item_id}", response_model=PlayerRead)
def patch_player(item_id: int, data: PlayerUpdate, db: Session = Depends(get_db)) -> Player:
    return update_player(item_id, data, db)

@router_player.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_player(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(Player).filter(Player.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Player not found")
    db.delete(obj)
    db.commit()

@router_player.post("/{item_id}/promote", response_model=bool)
def promote_player(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Player).filter(Player.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Player not found")
    result = obj.promote()
    db.commit()
    return result

@router_player.post("/{item_id}/demote", response_model=bool)
def demote_player(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Player).filter(Player.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Player not found")
    result = obj.demote()
    db.commit()
    return result

@router_player.post("/{item_id}/win", status_code=status.HTTP_204_NO_CONTENT)
def record_win_player(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Player).filter(Player.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Player not found")
    obj.record_win()
    db.commit()

@router_player.post("/{item_id}/loss", status_code=status.HTTP_204_NO_CONTENT)
def record_loss_player(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Player).filter(Player.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Player not found")
    obj.record_loss()
    db.commit()

@router_player.get("/{item_id}/win-rate", response_model=float)
def win_rate_player(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Player).filter(Player.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Player not found")
    result = obj.win_rate()
    db.commit()
    return result

@router_player.post("/{item_id}/verify", status_code=status.HTTP_204_NO_CONTENT)
def verify_player(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Player).filter(Player.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Player not found")
    obj.verify()
    db.commit()

@router_player.patch("/{item_id}/rating", status_code=status.HTTP_204_NO_CONTENT)
def update_rating_player(item_id: int, body: dict = {}, db: Session = Depends(get_db)):
    obj = db.query(Player).filter(Player.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Player not found")
    obj.update_rating(body.get("delta"))
    db.commit()

router_player_season_stats = APIRouter(prefix="/api/player_season_statses", tags=["Player Season Stats"])

@router_player_season_stats.get("", response_model=list[PlayerSeasonStatsRead])
def list_player_season_statses(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[PlayerSeasonStats]:
    return db.query(PlayerSeasonStats).offset(skip).limit(limit).all()

@router_player_season_stats.post("", response_model=PlayerSeasonStatsRead, status_code=status.HTTP_201_CREATED)
def create_player_season_stats(data: PlayerSeasonStatsCreate, db: Session = Depends(get_db)) -> PlayerSeasonStats:
    obj = PlayerSeasonStats(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_player_season_stats.get("/{item_id}", response_model=PlayerSeasonStatsRead)
def get_player_season_stats(item_id: int, db: Session = Depends(get_db)) -> PlayerSeasonStats:
    obj = db.query(PlayerSeasonStats).filter(PlayerSeasonStats.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="PlayerSeasonStats not found")
    return obj

@router_player_season_stats.put("/{item_id}", response_model=PlayerSeasonStatsRead)
def update_player_season_stats(item_id: int, data: PlayerSeasonStatsUpdate, db: Session = Depends(get_db)) -> PlayerSeasonStats:
    obj = db.query(PlayerSeasonStats).filter(PlayerSeasonStats.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="PlayerSeasonStats not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_player_season_stats.patch("/{item_id}", response_model=PlayerSeasonStatsRead)
def patch_player_season_stats(item_id: int, data: PlayerSeasonStatsUpdate, db: Session = Depends(get_db)) -> PlayerSeasonStats:
    return update_player_season_stats(item_id, data, db)

@router_player_season_stats.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_player_season_stats(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(PlayerSeasonStats).filter(PlayerSeasonStats.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="PlayerSeasonStats not found")
    db.delete(obj)
    db.commit()

router_player_collection = APIRouter(prefix="/api/player_collections", tags=["Player Collection"])

@router_player_collection.get("", response_model=list[PlayerCollectionRead])
def list_player_collections(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[PlayerCollection]:
    return db.query(PlayerCollection).offset(skip).limit(limit).all()

@router_player_collection.post("", response_model=PlayerCollectionRead, status_code=status.HTTP_201_CREATED)
def create_player_collection(data: PlayerCollectionCreate, db: Session = Depends(get_db)) -> PlayerCollection:
    obj = PlayerCollection(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_player_collection.get("/{item_id}", response_model=PlayerCollectionRead)
def get_player_collection(item_id: int, db: Session = Depends(get_db)) -> PlayerCollection:
    obj = db.query(PlayerCollection).filter(PlayerCollection.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="PlayerCollection not found")
    return obj

@router_player_collection.put("/{item_id}", response_model=PlayerCollectionRead)
def update_player_collection(item_id: int, data: PlayerCollectionUpdate, db: Session = Depends(get_db)) -> PlayerCollection:
    obj = db.query(PlayerCollection).filter(PlayerCollection.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="PlayerCollection not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_player_collection.patch("/{item_id}", response_model=PlayerCollectionRead)
def patch_player_collection(item_id: int, data: PlayerCollectionUpdate, db: Session = Depends(get_db)) -> PlayerCollection:
    return update_player_collection(item_id, data, db)

@router_player_collection.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_player_collection(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(PlayerCollection).filter(PlayerCollection.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="PlayerCollection not found")
    db.delete(obj)
    db.commit()

@router_player_collection.get("/{item_id}/api/collection/{id}/value", response_model=float)
def estimated_value_player_collection(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(PlayerCollection).filter(PlayerCollection.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="PlayerCollection not found")
    result = obj.estimated_value()
    db.commit()
    return result

router_friendship = APIRouter(prefix="/api/friendships", tags=["Friendship"])

@router_friendship.get("", response_model=list[FriendshipRead])
def list_friendships(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Friendship]:
    return db.query(Friendship).offset(skip).limit(limit).all()

@router_friendship.post("", response_model=FriendshipRead, status_code=status.HTTP_201_CREATED)
def create_friendship(data: FriendshipCreate, db: Session = Depends(get_db)) -> Friendship:
    obj = Friendship(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_friendship.get("/{item_id}", response_model=FriendshipRead)
def get_friendship(item_id: int, db: Session = Depends(get_db)) -> Friendship:
    obj = db.query(Friendship).filter(Friendship.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Friendship not found")
    return obj

@router_friendship.put("/{item_id}", response_model=FriendshipRead)
def update_friendship(item_id: int, data: FriendshipUpdate, db: Session = Depends(get_db)) -> Friendship:
    obj = db.query(Friendship).filter(Friendship.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Friendship not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_friendship.patch("/{item_id}", response_model=FriendshipRead)
def patch_friendship(item_id: int, data: FriendshipUpdate, db: Session = Depends(get_db)) -> Friendship:
    return update_friendship(item_id, data, db)

@router_friendship.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_friendship(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(Friendship).filter(Friendship.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Friendship not found")
    db.delete(obj)
    db.commit()

@router_friendship.post("/{item_id}/accept", status_code=status.HTTP_204_NO_CONTENT)
def accept_friendship(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Friendship).filter(Friendship.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Friendship not found")
    obj.accept()
    db.commit()

@router_friendship.post("/{item_id}/decline", status_code=status.HTTP_204_NO_CONTENT)
def decline_friendship(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Friendship).filter(Friendship.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Friendship not found")
    obj.decline()
    db.commit()

@router_friendship.post("/{item_id}/block", status_code=status.HTTP_204_NO_CONTENT)
def block_friendship(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Friendship).filter(Friendship.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Friendship not found")
    obj.block()
    db.commit()

router_achievement = APIRouter(prefix="/api/achievements", tags=["Achievement"])

@router_achievement.get("", response_model=list[AchievementRead])
def list_achievements(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Achievement]:
    return db.query(Achievement).offset(skip).limit(limit).all()

@router_achievement.post("", response_model=AchievementRead, status_code=status.HTTP_201_CREATED)
def create_achievement(data: AchievementCreate, db: Session = Depends(get_db)) -> Achievement:
    obj = Achievement(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_achievement.get("/{item_id}", response_model=AchievementRead)
def get_achievement(item_id: int, db: Session = Depends(get_db)) -> Achievement:
    obj = db.query(Achievement).filter(Achievement.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Achievement not found")
    return obj

@router_achievement.put("/{item_id}", response_model=AchievementRead)
def update_achievement(item_id: int, data: AchievementUpdate, db: Session = Depends(get_db)) -> Achievement:
    obj = db.query(Achievement).filter(Achievement.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Achievement not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_achievement.patch("/{item_id}", response_model=AchievementRead)
def patch_achievement(item_id: int, data: AchievementUpdate, db: Session = Depends(get_db)) -> Achievement:
    return update_achievement(item_id, data, db)

@router_achievement.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_achievement(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(Achievement).filter(Achievement.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Achievement not found")
    db.delete(obj)
    db.commit()

def _validate_player_achievement(obj: PlayerAchievement) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_implies())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_player_achievement = APIRouter(prefix="/api/player_achievements", tags=["Player Achievement"])

@router_player_achievement.get("", response_model=list[PlayerAchievementRead])
def list_player_achievements(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[PlayerAchievement]:
    return db.query(PlayerAchievement).offset(skip).limit(limit).all()

@router_player_achievement.post("", response_model=PlayerAchievementRead, status_code=status.HTTP_201_CREATED)
def create_player_achievement(data: PlayerAchievementCreate, db: Session = Depends(get_db)) -> PlayerAchievement:
    obj = PlayerAchievement(**data.model_dump(exclude_unset=True))
    _validate_player_achievement(obj)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_player_achievement.get("/{item_id}", response_model=PlayerAchievementRead)
def get_player_achievement(item_id: int, db: Session = Depends(get_db)) -> PlayerAchievement:
    obj = db.query(PlayerAchievement).filter(PlayerAchievement.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="PlayerAchievement not found")
    return obj

@router_player_achievement.put("/{item_id}", response_model=PlayerAchievementRead)
def update_player_achievement(item_id: int, data: PlayerAchievementUpdate, db: Session = Depends(get_db)) -> PlayerAchievement:
    obj = db.query(PlayerAchievement).filter(PlayerAchievement.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="PlayerAchievement not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    _validate_player_achievement(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_player_achievement.patch("/{item_id}", response_model=PlayerAchievementRead)
def patch_player_achievement(item_id: int, data: PlayerAchievementUpdate, db: Session = Depends(get_db)) -> PlayerAchievement:
    return update_player_achievement(item_id, data, db)

@router_player_achievement.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_player_achievement(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(PlayerAchievement).filter(PlayerAchievement.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="PlayerAchievement not found")
    db.delete(obj)
    db.commit()

def _validate_crafting_recipe(obj: CraftingRecipe) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_rules())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_crafting_recipe = APIRouter(prefix="/api/crafting_recipes", tags=["Crafting Recipe"])

@router_crafting_recipe.get("", response_model=list[CraftingRecipeRead])
def list_crafting_recipes(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[CraftingRecipe]:
    return db.query(CraftingRecipe).offset(skip).limit(limit).all()

@router_crafting_recipe.post("", response_model=CraftingRecipeRead, status_code=status.HTTP_201_CREATED)
def create_crafting_recipe(data: CraftingRecipeCreate, db: Session = Depends(get_db)) -> CraftingRecipe:
    obj = CraftingRecipe(**data.model_dump(exclude_unset=True))
    _validate_crafting_recipe(obj)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_crafting_recipe.get("/{item_id}", response_model=CraftingRecipeRead)
def get_crafting_recipe(item_id: int, db: Session = Depends(get_db)) -> CraftingRecipe:
    obj = db.query(CraftingRecipe).filter(CraftingRecipe.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CraftingRecipe not found")
    return obj

@router_crafting_recipe.put("/{item_id}", response_model=CraftingRecipeRead)
def update_crafting_recipe(item_id: int, data: CraftingRecipeUpdate, db: Session = Depends(get_db)) -> CraftingRecipe:
    obj = db.query(CraftingRecipe).filter(CraftingRecipe.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CraftingRecipe not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    _validate_crafting_recipe(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_crafting_recipe.patch("/{item_id}", response_model=CraftingRecipeRead)
def patch_crafting_recipe(item_id: int, data: CraftingRecipeUpdate, db: Session = Depends(get_db)) -> CraftingRecipe:
    return update_crafting_recipe(item_id, data, db)

@router_crafting_recipe.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_crafting_recipe(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(CraftingRecipe).filter(CraftingRecipe.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CraftingRecipe not found")
    db.delete(obj)
    db.commit()

router_crafting_ingredient = APIRouter(prefix="/api/crafting_ingredients", tags=["Crafting Ingredient"])

@router_crafting_ingredient.get("", response_model=list[CraftingIngredientRead])
def list_crafting_ingredients(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[CraftingIngredient]:
    return db.query(CraftingIngredient).offset(skip).limit(limit).all()

@router_crafting_ingredient.post("", response_model=CraftingIngredientRead, status_code=status.HTTP_201_CREATED)
def create_crafting_ingredient(data: CraftingIngredientCreate, db: Session = Depends(get_db)) -> CraftingIngredient:
    obj = CraftingIngredient(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_crafting_ingredient.get("/{item_id}", response_model=CraftingIngredientRead)
def get_crafting_ingredient(item_id: int, db: Session = Depends(get_db)) -> CraftingIngredient:
    obj = db.query(CraftingIngredient).filter(CraftingIngredient.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CraftingIngredient not found")
    return obj

@router_crafting_ingredient.put("/{item_id}", response_model=CraftingIngredientRead)
def update_crafting_ingredient(item_id: int, data: CraftingIngredientUpdate, db: Session = Depends(get_db)) -> CraftingIngredient:
    obj = db.query(CraftingIngredient).filter(CraftingIngredient.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CraftingIngredient not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_crafting_ingredient.patch("/{item_id}", response_model=CraftingIngredientRead)
def patch_crafting_ingredient(item_id: int, data: CraftingIngredientUpdate, db: Session = Depends(get_db)) -> CraftingIngredient:
    return update_crafting_ingredient(item_id, data, db)

@router_crafting_ingredient.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_crafting_ingredient(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(CraftingIngredient).filter(CraftingIngredient.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CraftingIngredient not found")
    db.delete(obj)
    db.commit()
