"""
Domain services for the Players BC bounded context.
Place business logic that doesn't belong to a single model here.
"""


class PlayerService:
    """Domain service for Player aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new Player."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing Player."""
        raise NotImplementedError

    @staticmethod
    def promote(id):
        from .models import Player
        instance = Player.objects.get(pk=id)
        result = instance.promote()
        instance.save()
        return result

    @staticmethod
    def demote(id):
        from .models import Player
        instance = Player.objects.get(pk=id)
        result = instance.demote()
        instance.save()
        return result

    @staticmethod
    def record_win(id):
        from .models import Player
        instance = Player.objects.get(pk=id)
        instance.record_win()
        instance.save()

    @staticmethod
    def record_loss(id):
        from .models import Player
        instance = Player.objects.get(pk=id)
        instance.record_loss()
        instance.save()

    @staticmethod
    def win_rate(id):
        from .models import Player
        instance = Player.objects.get(pk=id)
        result = instance.win_rate()
        instance.save()
        return result

    @staticmethod
    def verify(id):
        from .models import Player
        instance = Player.objects.get(pk=id)
        instance.verify()
        instance.save()

    @staticmethod
    def update_rating(id, delta):
        from .models import Player
        instance = Player.objects.get(pk=id)
        instance.update_rating(delta)
        instance.save()


class PlayerSeasonStatsService:
    """Domain service for PlayerSeasonStats aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new PlayerSeasonStats."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing PlayerSeasonStats."""
        raise NotImplementedError

    @staticmethod
    def win_rate(id):
        from .models import PlayerSeasonStats
        instance = PlayerSeasonStats.objects.get(pk=id)
        result = instance.win_rate()
        instance.save()
        return result

    @staticmethod
    def add_points(id, points):
        from .models import PlayerSeasonStats
        instance = PlayerSeasonStats.objects.get(pk=id)
        instance.add_points(points)
        instance.save()

    @staticmethod
    def record_tournament_win(id):
        from .models import PlayerSeasonStats
        instance = PlayerSeasonStats.objects.get(pk=id)
        instance.record_tournament_win()
        instance.save()


class PlayerCollectionService:
    """Domain service for PlayerCollection aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new PlayerCollection."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing PlayerCollection."""
        raise NotImplementedError

    @staticmethod
    def add(id, quantity):
        from .models import PlayerCollection
        instance = PlayerCollection.objects.get(pk=id)
        instance.add(quantity)
        instance.save()

    @staticmethod
    def remove(id, quantity):
        from .models import PlayerCollection
        instance = PlayerCollection.objects.get(pk=id)
        instance.remove(quantity)
        instance.save()

    @staticmethod
    def estimated_value(id):
        from .models import PlayerCollection
        instance = PlayerCollection.objects.get(pk=id)
        result = instance.estimated_value()
        instance.save()
        return result


class FriendshipService:
    """Domain service for Friendship aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new Friendship."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing Friendship."""
        raise NotImplementedError

    @staticmethod
    def accept(id):
        from .models import Friendship
        instance = Friendship.objects.get(pk=id)
        instance.accept()
        instance.save()

    @staticmethod
    def decline(id):
        from .models import Friendship
        instance = Friendship.objects.get(pk=id)
        instance.decline()
        instance.save()

    @staticmethod
    def block(id):
        from .models import Friendship
        instance = Friendship.objects.get(pk=id)
        instance.block()
        instance.save()


class AchievementService:
    """Domain service for Achievement aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new Achievement."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing Achievement."""
        raise NotImplementedError

    @staticmethod
    def point_value(id):
        from .models import Achievement
        instance = Achievement.objects.get(pk=id)
        result = instance.point_value(multiplier)
        instance.save()
        return result

    @staticmethod
    def reveal(id):
        from .models import Achievement
        instance = Achievement.objects.get(pk=id)
        instance.reveal()
        instance.save()


class PlayerAchievementService:
    """Domain service for PlayerAchievement aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new PlayerAchievement."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing PlayerAchievement."""
        raise NotImplementedError

    @staticmethod
    def increment_progress(id, amount):
        from .models import PlayerAchievement
        instance = PlayerAchievement.objects.get(pk=id)
        instance.increment_progress(amount)
        instance.save()

    @staticmethod
    def complete(id):
        from .models import PlayerAchievement
        instance = PlayerAchievement.objects.get(pk=id)
        instance.complete()
        instance.save()

    # triggered by @on(is_completed = true)
    @staticmethod
    def set_is_completed(pk, value):
        from .models import PlayerAchievement, PlayerAchievementIsCompletedChoices
        instance = PlayerAchievement.objects.get(pk=pk)
        instance.is_completed = value
        if value == PlayerAchievementIsCompletedChoices.TRUE:
            instance.complete()
        instance.save()


class CraftingRecipeService:
    """Domain service for CraftingRecipe aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new CraftingRecipe."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing CraftingRecipe."""
        raise NotImplementedError

    @staticmethod
    def can_craft(id):
        from .models import CraftingRecipe
        instance = CraftingRecipe.objects.get(pk=id)
        result = instance.can_craft(player_id)
        instance.save()
        return result

    @staticmethod
    def execute_craft(id, player_id):
        from .models import CraftingRecipe
        instance = CraftingRecipe.objects.get(pk=id)
        instance.execute_craft(player_id)
        instance.save()

    @staticmethod
    def disable(id):
        from .models import CraftingRecipe
        instance = CraftingRecipe.objects.get(pk=id)
        instance.disable()
        instance.save()

    @staticmethod
    def enable(id):
        from .models import CraftingRecipe
        instance = CraftingRecipe.objects.get(pk=id)
        instance.enable()
        instance.save()


class CraftingIngredientService:
    """Domain service for CraftingIngredient aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new CraftingIngredient."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing CraftingIngredient."""
        raise NotImplementedError
