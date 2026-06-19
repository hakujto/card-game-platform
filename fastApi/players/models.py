from __future__ import annotations

from sqlalchemy import (
    Boolean, Column, Date, DateTime, Float, ForeignKey, Integer,
    JSON, Numeric, SmallInteger, String, Table, Text,
)
from sqlalchemy.orm import relationship

from app.db import Base

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
    user_id = Column(Integer, ForeignKey("user.id", ondelete="CASCADE"), nullable=True, unique=True)
    user = relationship("User", foreign_keys=[user_id], backref="player_profile", uselist=False)

    def promote(self) -> bool:
        # TODO: implement promote
        return None  # type: ignore

    def demote(self) -> bool:
        # TODO: implement demote
        return None  # type: ignore

    def record_win(self):
        # TODO: implement record_win
        pass

    def record_loss(self):
        # TODO: implement record_loss
        pass

    def win_rate(self) -> float:
        # TODO: implement win_rate
        return None  # type: ignore

    def verify(self):
        # TODO: implement verify
        pass

    def update_rating(self, delta: int):
        # TODO: implement update_rating
        pass


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.rating is None or (self.rating >= 0 and self.rating <= 9999))):
            errors.append("Rating must be between 0 and 9999")
        if not ((self.peak_rating is None or (self.rating is not None and self.peak_rating >= self.rating))):
            errors.append("Peak rating must be greater than or equal to current rating")
        if not (self.display_name is not None):
            errors.append("Display name must not be empty")
        return errors
    # ── Lifecycle hooks ──────────────────────────────────────────────
    def _hook_update_rank(self) -> None:
        # TODO: implement update_rank
        pass

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
    player_id = Column(Integer, ForeignKey("player.id", ondelete="CASCADE"), nullable=True)
    player = relationship("Player", foreign_keys=[player_id], backref="season_stats")
    season_id = Column(Integer, ForeignKey("season.id", ondelete="CASCADE"), nullable=False)
    season = relationship("Season", foreign_keys=[season_id], backref="player_stats")

    def win_rate(self) -> float:
        # TODO: implement win_rate
        return None  # type: ignore

    def add_points(self, points: int):
        # TODO: implement add_points
        pass

    def record_tournament_win(self):
        # TODO: implement record_tournament_win
        pass


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
    player_id = Column(Integer, ForeignKey("player.id", ondelete="CASCADE"), nullable=False)
    player = relationship("Player", foreign_keys=[player_id], backref="collection")
    card_id = Column(Integer, ForeignKey("card.id", ondelete="CASCADE"), nullable=False)
    card = relationship("Card", foreign_keys=[card_id], backref="player_collections")

    def add(self, quantity: int):
        # TODO: implement add
        pass

    def remove(self, quantity: int):
        # TODO: implement remove
        pass

    def estimated_value(self) -> float:
        # TODO: implement estimated_value
        return None  # type: ignore


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
    requester_id = Column(Integer, ForeignKey("player.id", ondelete="CASCADE"), nullable=False)
    requester = relationship("Player", foreign_keys=[requester_id], backref="sent_friend_requests")
    receiver_id = Column(Integer, ForeignKey("player.id", ondelete="CASCADE"), nullable=False)
    receiver = relationship("Player", foreign_keys=[receiver_id], backref="received_friend_requests")

    def accept(self):
        # TODO: implement accept
        pass

    def decline(self):
        # TODO: implement decline
        pass

    def block(self):
        # TODO: implement block
        pass

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
        # TODO: implement point_value
        return None  # type: ignore

    def reveal(self):
        # TODO: implement reveal
        pass


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
    player_id = Column(Integer, ForeignKey("player.id", ondelete="CASCADE"), nullable=False)
    player = relationship("Player", foreign_keys=[player_id], backref="achievement_records")
    achievement_id = Column(Integer, ForeignKey("achievement.id", ondelete="CASCADE"), nullable=False)
    achievement = relationship("Achievement", foreign_keys=[achievement_id], backref="player_records")

    def increment_progress(self, amount: int):
        # TODO: implement increment_progress
        pass

    def complete(self):
        # TODO: implement complete
        pass


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
    result_card_id = Column(Integer, ForeignKey("card.id", ondelete="CASCADE"), nullable=False)
    result_card = relationship("Card", foreign_keys=[result_card_id], backref="crafting_recipes")

    def can_craft(self, player_id: int) -> bool:
        # TODO: implement can_craft
        return None  # type: ignore

    def execute_craft(self, player_id: int):
        # TODO: implement execute_craft
        pass

    def disable(self):
        # TODO: implement disable
        pass

    def enable(self):
        # TODO: implement enable
        pass


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
    recipe_id = Column(Integer, ForeignKey("crafting_recipe.id", ondelete="CASCADE"), nullable=False)
    recipe = relationship("CraftingRecipe", foreign_keys=[recipe_id], backref="ingredients")
    card_id = Column(Integer, ForeignKey("card.id", ondelete="CASCADE"), nullable=False)
    card = relationship("Card", foreign_keys=[card_id], backref="used_in_recipes")
    def __repr__(self) -> str:
        return f"<CraftingIngredient id={{self.id}}>"



# ── SQLAlchemy event listeners ───────────────────────────────────────────
from sqlalchemy import event

@event.listens_for(Player, "after_update")
def _player_update_rank(mapper, connection, target):
    target._hook_update_rank()
