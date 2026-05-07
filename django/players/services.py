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
