"""
Domain services for the Players BC bounded context.
Place business logic that does not belong to a single model here.
"""

from sqlalchemy.orm import Session

from .models import Player, PlayerSeasonStats, PlayerCollection, Friendship, Achievement, PlayerAchievement, CraftingRecipe, CraftingIngredient


class PlayerService:
    """Domain service for Player aggregate."""

    @staticmethod
    def promote(db: Session, pk: int) -> bool:
        obj = db.query(Player).filter(Player.id == pk).first()
        if obj is None:
            raise ValueError("Player not found: " + str(pk))
        result = obj.promote()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def demote(db: Session, pk: int) -> bool:
        obj = db.query(Player).filter(Player.id == pk).first()
        if obj is None:
            raise ValueError("Player not found: " + str(pk))
        result = obj.demote()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def record_win(db: Session, pk: int):
        obj = db.query(Player).filter(Player.id == pk).first()
        if obj is None:
            raise ValueError("Player not found: " + str(pk))
        obj.record_win()
        db.add(obj)
        db.commit()

    @staticmethod
    def record_loss(db: Session, pk: int):
        obj = db.query(Player).filter(Player.id == pk).first()
        if obj is None:
            raise ValueError("Player not found: " + str(pk))
        obj.record_loss()
        db.add(obj)
        db.commit()

    @staticmethod
    def win_rate(db: Session, pk: int) -> float:
        obj = db.query(Player).filter(Player.id == pk).first()
        if obj is None:
            raise ValueError("Player not found: " + str(pk))
        result = obj.win_rate()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def verify(db: Session, pk: int):
        obj = db.query(Player).filter(Player.id == pk).first()
        if obj is None:
            raise ValueError("Player not found: " + str(pk))
        obj.verify()
        db.add(obj)
        db.commit()

    @staticmethod
    def update_rating(db: Session, pk: int, delta: int):
        obj = db.query(Player).filter(Player.id == pk).first()
        if obj is None:
            raise ValueError("Player not found: " + str(pk))
        obj.update_rating(delta)
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class PlayerSeasonStatsService:
    """Domain service for PlayerSeasonStats aggregate."""

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class PlayerCollectionService:
    """Domain service for PlayerCollection aggregate."""

    @staticmethod
    def estimated_value(db: Session, pk: int) -> float:
        obj = db.query(PlayerCollection).filter(PlayerCollection.id == pk).first()
        if obj is None:
            raise ValueError("PlayerCollection not found: " + str(pk))
        result = obj.estimated_value()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class FriendshipService:
    """Domain service for Friendship aggregate."""

    @staticmethod
    def accept(db: Session, pk: int):
        obj = db.query(Friendship).filter(Friendship.id == pk).first()
        if obj is None:
            raise ValueError("Friendship not found: " + str(pk))
        obj.accept()
        db.add(obj)
        db.commit()

    @staticmethod
    def decline(db: Session, pk: int):
        obj = db.query(Friendship).filter(Friendship.id == pk).first()
        if obj is None:
            raise ValueError("Friendship not found: " + str(pk))
        obj.decline()
        db.add(obj)
        db.commit()

    @staticmethod
    def block(db: Session, pk: int):
        obj = db.query(Friendship).filter(Friendship.id == pk).first()
        if obj is None:
            raise ValueError("Friendship not found: " + str(pk))
        obj.block()
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class AchievementService:
    """Domain service for Achievement aggregate."""

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class PlayerAchievementService:
    """Domain service for PlayerAchievement aggregate."""

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class CraftingRecipeService:
    """Domain service for CraftingRecipe aggregate."""

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class CraftingIngredientService:
    """Domain service for CraftingIngredient aggregate."""

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError
