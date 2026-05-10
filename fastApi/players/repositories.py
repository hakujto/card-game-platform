"""
Repository layer for the Players BC bounded context.
Abstracts data access from domain logic.
"""

from sqlalchemy.orm import Session

from .models import Player, PlayerSeasonStats, PlayerCollection, Friendship, Achievement, PlayerAchievement, CraftingRecipe, CraftingIngredient


class PlayerRepository:
    """Repository for Player."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> Player | None:
        return db.query(Player).filter(Player.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[Player]:
        return db.query(Player).all()


class PlayerSeasonStatsRepository:
    """Repository for PlayerSeasonStats."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> PlayerSeasonStats | None:
        return db.query(PlayerSeasonStats).filter(PlayerSeasonStats.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[PlayerSeasonStats]:
        return db.query(PlayerSeasonStats).all()


class PlayerCollectionRepository:
    """Repository for PlayerCollection."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> PlayerCollection | None:
        return db.query(PlayerCollection).filter(PlayerCollection.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[PlayerCollection]:
        return db.query(PlayerCollection).all()


class FriendshipRepository:
    """Repository for Friendship."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> Friendship | None:
        return db.query(Friendship).filter(Friendship.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[Friendship]:
        return db.query(Friendship).all()


class AchievementRepository:
    """Repository for Achievement."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> Achievement | None:
        return db.query(Achievement).filter(Achievement.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[Achievement]:
        return db.query(Achievement).all()


class PlayerAchievementRepository:
    """Repository for PlayerAchievement."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> PlayerAchievement | None:
        return db.query(PlayerAchievement).filter(PlayerAchievement.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[PlayerAchievement]:
        return db.query(PlayerAchievement).all()


class CraftingRecipeRepository:
    """Repository for CraftingRecipe."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> CraftingRecipe | None:
        return db.query(CraftingRecipe).filter(CraftingRecipe.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[CraftingRecipe]:
        return db.query(CraftingRecipe).all()


class CraftingIngredientRepository:
    """Repository for CraftingIngredient."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> CraftingIngredient | None:
        return db.query(CraftingIngredient).filter(CraftingIngredient.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[CraftingIngredient]:
        return db.query(CraftingIngredient).all()
