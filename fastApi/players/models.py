from __future__ import annotations

from sqlalchemy import (
    Boolean, Column, Date, DateTime, Float, ForeignKey, Integer,
    JSON, Numeric, SmallInteger, String, Table, Text,
)
from sqlalchemy.orm import relationship

from app.db import Base

player_achievements_assoc = Table(
    "player_achievements_m2m",
    Base.metadata,
    Column("player_id", Integer, ForeignKey("player.id"), primary_key=True),
    Column("achievement_id", Integer, ForeignKey("achievement.id"), primary_key=True),
)

player_friends_assoc = Table(
    "player_friends_m2m",
    Base.metadata,
    Column("left_id", Integer, ForeignKey("player.id"), primary_key=True),
    Column("right_id", Integer, ForeignKey("player.id"), primary_key=True),
)

crafting_recipe_required_cards_assoc = Table(
    "crafting_recipe_required_cards_m2m",
    Base.metadata,
    Column("crafting_recipe_id", Integer, ForeignKey("crafting_recipe.id"), primary_key=True),
    Column("card_id", Integer, ForeignKey("card.id"), primary_key=True),
)

from typing import Literal

PlayerRankType = Literal["Bronze", "Silver", "Gold", "Platinum", "Diamond", "Master", "Grandmaster"]
PlayerPreferredFormatType = Literal["Standard", "Extended", "Legacy", "Vintage", "Commander", "Draft"]

class Player(Base):
    __tablename__ = "player"

    id = Column(Integer, primary_key=True, index=True)
    display_name = Column(String(50))
    rank = Column(String(20), default="Bronze")
    rating = Column(Integer, default="1000")
    peak_rating = Column(Integer, default="1000")
    bio = Column(Text, nullable=True)
    country_code = Column(String(2), nullable=True)
    avatar_url = Column(String(200), nullable=True)
    preferred_format = Column(String(20), nullable=True)
    is_verified = Column(Boolean, default="false")
    created_at = Column(DateTime)
    last_active_at = Column(DateTime, nullable=True)
    user_id = Column(Integer, ForeignKey("user.id"), nullable=True)
    user = relationship("User", foreign_keys=[user_id])
    achievements = relationship("Achievement", secondary=player_achievements_assoc)
    friends = relationship(
        "Player", secondary=player_friends_assoc,
        primaryjoin=id == player_friends_assoc.c.left_id,
        secondaryjoin=id == player_friends_assoc.c.right_id,
    )

    def promote(self) -> bool:
        raise NotImplementedError("promote not implemented")

    def demote(self) -> bool:
        raise NotImplementedError("demote not implemented")

    def record_win(self):
        raise NotImplementedError("record_win not implemented")

    def record_loss(self):
        raise NotImplementedError("record_loss not implemented")

    def win_rate(self) -> float:
        raise NotImplementedError("win_rate not implemented")

    def verify(self):
        raise NotImplementedError("verify not implemented")

    def update_rating(self, delta: int):
        raise NotImplementedError("update_rating not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.rating is None or (self.rating >= 0 and self.rating <= 9999))):
            errors.append("Rating must be between 0 and 9999")
        if not ((self.peak_rating is None or (self.rating is not None and self.peak_rating >= self.rating))):
            errors.append("Peak rating must be greater than or equal to current rating")
        if not (self.display_name is not None):
            errors.append("Display name must not be empty")
        return errors
    def __repr__(self) -> str:
        return f"<Player id={{self.id}}>"


from typing import Literal

PlayerSeasonStatsHighestRankType = Literal["Bronze", "Silver", "Gold", "Platinum", "Diamond", "Master", "Grandmaster"]

class PlayerSeasonStats(Base):
    __tablename__ = "player_season_stats"

    id = Column(Integer, primary_key=True, index=True)
    wins = Column(Integer, default="0")
    losses = Column(Integer, default="0")
    draws = Column(Integer, default="0")
    tournament_wins = Column(Integer, default="0")
    highest_rank = Column(String(20), nullable=True)
    season_points = Column(Integer, default="0")
    player_id = Column(Integer, ForeignKey("player.id"), nullable=True)
    player = relationship("Player", foreign_keys=[player_id])
    season_id = Column(Integer, ForeignKey("season.id"), nullable=False)
    season = relationship("Season", foreign_keys=[season_id])

    def win_rate(self) -> float:
        raise NotImplementedError("win_rate not implemented")

    def add_points(self, points: int):
        raise NotImplementedError("add_points not implemented")

    def record_tournament_win(self):
        raise NotImplementedError("record_tournament_win not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.wins is None or self.wins >= 0)):
            errors.append("Season wins must not be negative")
        if not ((self.losses is None or self.losses >= 0)):
            errors.append("Season losses must not be negative")
        if not ((self.tournament_wins is None or self.tournament_wins >= 0)):
            errors.append("Season tournament wins must not be negative")
        if not ((self.season_points is None or self.season_points >= 0)):
            errors.append("Season points must not be negative")
        return errors
    def __repr__(self) -> str:
        return f"<PlayerSeasonStats id={{self.id}}>"


from typing import Literal

PlayerCollectionConditionType = Literal["Mint", "NearMint", "Excellent", "Good", "Played"]
PlayerCollectionAcquiredViaType = Literal["Purchase", "Trade", "TournamentReward", "Pack", "Craft"]

class PlayerCollection(Base):
    __tablename__ = "player_collection"

    id = Column(Integer, primary_key=True, index=True)
    quantity = Column(Integer, default="1")
    foil = Column(Boolean, default="false")
    condition = Column(String(20), default="Mint")
    acquired_at = Column(DateTime)
    acquired_via = Column(String(20), default="Purchase")
    player_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    player = relationship("Player", foreign_keys=[player_id])
    card_id = Column(Integer, ForeignKey("card.id"), nullable=False)
    card = relationship("Card", foreign_keys=[card_id])

    def add(self, quantity: int):
        raise NotImplementedError("add not implemented")

    def remove(self, quantity: int):
        raise NotImplementedError("remove not implemented")

    def estimated_value(self) -> float:
        raise NotImplementedError("estimated_value not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.quantity is None or self.quantity > 0)):
            errors.append("Collection quantity must be greater than zero")
        return errors
    def __repr__(self) -> str:
        return f"<PlayerCollection id={{self.id}}>"


from typing import Literal

FriendshipStatusType = Literal["Pending", "Accepted", "Blocked"]

class Friendship(Base):
    __tablename__ = "friendship"

    id = Column(Integer, primary_key=True, index=True)
    status = Column(String(20), default="Pending")
    created_at = Column(DateTime)
    requester_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    requester = relationship("Player", foreign_keys=[requester_id])
    receiver_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    receiver = relationship("Player", foreign_keys=[receiver_id])

    def accept(self):
        raise NotImplementedError("accept not implemented")

    def decline(self):
        raise NotImplementedError("decline not implemented")

    def block(self):
        raise NotImplementedError("block not implemented")

    def __repr__(self) -> str:
        return f"<Friendship id={{self.id}}>"


from typing import Literal

AchievementRarityType = Literal["Common", "Uncommon", "Rare", "Epic", "Legendary"]

class Achievement(Base):
    __tablename__ = "achievement"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200))
    description = Column(Text)
    icon_url = Column(String(200), nullable=True)
    points = Column(Integer, default="10")
    rarity = Column(String(20), default="Common")
    is_hidden = Column(Boolean, default="false")

    def point_value(self, multiplier: int) -> int:
        raise NotImplementedError("point_value not implemented")

    def reveal(self):
        raise NotImplementedError("reveal not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.points is None or self.points > 0)):
            errors.append("Achievement must award at least one point")
        return errors
    def __repr__(self) -> str:
        return f"<Achievement id={{self.id}}>"


class PlayerAchievement(Base):
    __tablename__ = "player_achievement"

    id = Column(Integer, primary_key=True, index=True)
    earned_at = Column(DateTime)
    progress = Column(Integer, default="0")
    is_completed = Column(Boolean, default="false")
    player_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    player = relationship("Player", foreign_keys=[player_id])
    achievement_id = Column(Integer, ForeignKey("achievement.id"), nullable=False)
    achievement = relationship("Achievement", foreign_keys=[achievement_id])

    def increment_progress(self, amount: int):
        raise NotImplementedError("increment_progress not implemented")

    def complete(self):
        raise NotImplementedError("complete not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.progress is None or self.progress >= 0)):
            errors.append("Achievement progress must not be negative")
        return errors

    def validate_implies(self) -> list[str]:
        errors = []
        if (self.is_completed is True) and not ((self.progress is None or self.progress > 0)):
            errors.append("Completed achievement must have progress greater than zero")
        return errors
    def __repr__(self) -> str:
        return f"<PlayerAchievement id={{self.id}}>"


class CraftingRecipe(Base):
    __tablename__ = "crafting_recipe"

    id = Column(Integer, primary_key=True, index=True)
    dust_cost = Column(Integer)
    is_available = Column(Boolean, default="true")
    result_card_id = Column(Integer, ForeignKey("card.id"), nullable=False)
    result_card = relationship("Card", foreign_keys=[result_card_id])
    required_cards = relationship("Card", secondary=crafting_recipe_required_cards_assoc)

    def can_craft(self, player_id: int) -> bool:
        raise NotImplementedError("can_craft not implemented")

    def execute_craft(self, player_id: int):
        raise NotImplementedError("execute_craft not implemented")

    def disable(self):
        raise NotImplementedError("disable not implemented")

    def enable(self):
        raise NotImplementedError("enable not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.dust_cost is None or self.dust_cost > 0)):
            errors.append("Crafting recipe must have a dust cost greater than zero")
        return errors
    def __repr__(self) -> str:
        return f"<CraftingRecipe id={{self.id}}>"


class CraftingIngredient(Base):
    __tablename__ = "crafting_ingredient"

    id = Column(Integer, primary_key=True, index=True)
    quantity = Column(Integer, default="1")
    recipe_id = Column(Integer, ForeignKey("crafting_recipe.id"), nullable=False)
    recipe = relationship("CraftingRecipe", foreign_keys=[recipe_id])
    card_id = Column(Integer, ForeignKey("card.id"), nullable=False)
    card = relationship("Card", foreign_keys=[card_id])
    def __repr__(self) -> str:
        return f"<CraftingIngredient id={{self.id}}>"
