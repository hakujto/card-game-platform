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
    season_stats_id = Column(Integer, ForeignKey("player_season_stats.id"), nullable=False)
    season_stats = relationship("PlayerSeasonStats", foreign_keys=[season_stats_id])
    achievements = relationship("Achievement", secondary=player_achievements_assoc)
    friends = relationship(
        "Player", secondary=player_friends_assoc,
        primaryjoin=id == player_friends_assoc.c.left_id,
        secondaryjoin=id == player_friends_assoc.c.right_id,
    )

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
