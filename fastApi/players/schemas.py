from __future__ import annotations

from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict

class PlayerBase(BaseModel):
    display_name: str
    rank: str
    rating: int
    peak_rating: int
    bio: str | None = None
    country_code: str | None = None
    avatar_url: str | None = None
    preferred_format: str | None = None
    is_verified: bool
    created_at: datetime
    last_active_at: datetime | None = None
    user_id: int | None = None
    achievements_ids: list[int] = []
    friends_ids: list[int] = []


class PlayerCreate(PlayerBase):
    pass


class PlayerUpdate(BaseModel):
    display_name: str | None = None
    rank: str | None = None
    rating: int | None = None
    peak_rating: int | None = None
    bio: str | None = None
    country_code: str | None = None
    avatar_url: str | None = None
    preferred_format: str | None = None
    is_verified: bool | None = None
    created_at: datetime | None = None
    last_active_at: datetime | None = None
    user_id: int | None = None
    achievements_ids: list[int] | None = None
    friends_ids: list[int] | None = None


class PlayerRead(PlayerBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class PlayerSeasonStatsBase(BaseModel):
    wins: int
    losses: int
    draws: int
    tournament_wins: int
    highest_rank: str | None = None
    season_points: int
    player_id: int | None = None
    season_id: int


class PlayerSeasonStatsCreate(PlayerSeasonStatsBase):
    pass


class PlayerSeasonStatsUpdate(BaseModel):
    wins: int | None = None
    losses: int | None = None
    draws: int | None = None
    tournament_wins: int | None = None
    highest_rank: str | None = None
    season_points: int | None = None
    player_id: int | None = None
    season_id: int | None = None


class PlayerSeasonStatsRead(PlayerSeasonStatsBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class PlayerCollectionBase(BaseModel):
    quantity: int
    foil: bool
    condition: str
    acquired_at: datetime
    acquired_via: str
    player_id: int
    card_id: int


class PlayerCollectionCreate(PlayerCollectionBase):
    pass


class PlayerCollectionUpdate(BaseModel):
    quantity: int | None = None
    foil: bool | None = None
    condition: str | None = None
    acquired_at: datetime | None = None
    acquired_via: str | None = None
    player_id: int | None = None
    card_id: int | None = None


class PlayerCollectionRead(PlayerCollectionBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class FriendshipBase(BaseModel):
    status: str
    created_at: datetime
    requester_id: int
    receiver_id: int


class FriendshipCreate(FriendshipBase):
    pass


class FriendshipUpdate(BaseModel):
    status: str | None = None
    created_at: datetime | None = None
    requester_id: int | None = None
    receiver_id: int | None = None


class FriendshipRead(FriendshipBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class AchievementBase(BaseModel):
    name: str
    description: str
    icon_url: str | None = None
    points: int
    rarity: str
    is_hidden: bool


class AchievementCreate(AchievementBase):
    pass


class AchievementUpdate(BaseModel):
    name: str | None = None
    description: str | None = None
    icon_url: str | None = None
    points: int | None = None
    rarity: str | None = None
    is_hidden: bool | None = None


class AchievementRead(AchievementBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class PlayerAchievementBase(BaseModel):
    earned_at: datetime
    progress: int
    is_completed: bool
    player_id: int
    achievement_id: int


class PlayerAchievementCreate(PlayerAchievementBase):
    pass


class PlayerAchievementUpdate(BaseModel):
    earned_at: datetime | None = None
    progress: int | None = None
    is_completed: bool | None = None
    player_id: int | None = None
    achievement_id: int | None = None


class PlayerAchievementRead(PlayerAchievementBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class CraftingRecipeBase(BaseModel):
    dust_cost: int
    is_available: bool
    result_card_id: int
    required_cards_ids: list[int] = []


class CraftingRecipeCreate(CraftingRecipeBase):
    pass


class CraftingRecipeUpdate(BaseModel):
    dust_cost: int | None = None
    is_available: bool | None = None
    result_card_id: int | None = None
    required_cards_ids: list[int] | None = None


class CraftingRecipeRead(CraftingRecipeBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class CraftingIngredientBase(BaseModel):
    quantity: int
    recipe_id: int
    card_id: int


class CraftingIngredientCreate(CraftingIngredientBase):
    pass


class CraftingIngredientUpdate(BaseModel):
    quantity: int | None = None
    recipe_id: int | None = None
    card_id: int | None = None


class CraftingIngredientRead(CraftingIngredientBase):
    id: int
    model_config = ConfigDict(from_attributes=True)
