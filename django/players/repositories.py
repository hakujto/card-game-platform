"""
Repository layer for the Players BC bounded context.
Abstracts data access from domain logic.
"""


class PlayerRepository:
    """Repository for Player."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import Player
        return Player.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import Player
        return Player.objects.all()


class PlayerSeasonStatsRepository:
    """Repository for PlayerSeasonStats."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import PlayerSeasonStats
        return PlayerSeasonStats.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import PlayerSeasonStats
        return PlayerSeasonStats.objects.all()


class PlayerCollectionRepository:
    """Repository for PlayerCollection."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import PlayerCollection
        return PlayerCollection.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import PlayerCollection
        return PlayerCollection.objects.all()


class FriendshipRepository:
    """Repository for Friendship."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import Friendship
        return Friendship.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import Friendship
        return Friendship.objects.all()


class AchievementRepository:
    """Repository for Achievement."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import Achievement
        return Achievement.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import Achievement
        return Achievement.objects.all()


class PlayerAchievementRepository:
    """Repository for PlayerAchievement."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import PlayerAchievement
        return PlayerAchievement.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import PlayerAchievement
        return PlayerAchievement.objects.all()


class CraftingRecipeRepository:
    """Repository for CraftingRecipe."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import CraftingRecipe
        return CraftingRecipe.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import CraftingRecipe
        return CraftingRecipe.objects.all()


class CraftingIngredientRepository:
    """Repository for CraftingIngredient."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import CraftingIngredient
        return CraftingIngredient.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import CraftingIngredient
        return CraftingIngredient.objects.all()
