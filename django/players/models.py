from django.conf import settings
from django.db import models


class PlayerRankChoices(models.TextChoices):
    BRONZE = "Bronze", "Bronze"
    SILVER = "Silver", "Silver"
    GOLD = "Gold", "Gold"
    PLATINUM = "Platinum", "Platinum"
    DIAMOND = "Diamond", "Diamond"
    MASTER = "Master", "Master"
    GRANDMASTER = "Grandmaster", "Grandmaster"


class PlayerPreferredFormatChoices(models.TextChoices):
    STANDARD = "Standard", "Standard"
    EXTENDED = "Extended", "Extended"
    LEGACY = "Legacy", "Legacy"
    VINTAGE = "Vintage", "Vintage"
    COMMANDER = "Commander", "Commander"
    DRAFT = "Draft", "Draft"


class Player(models.Model):
    display_name = models.CharField(max_length=50)
    rank = models.CharField(max_length=20, choices=PlayerRankChoices.choices, default=PlayerRankChoices.BRONZE)
    rating = models.IntegerField(default=1000)
    peak_rating = models.IntegerField(default=1000)
    bio = models.TextField(null=True, blank=True)
    country_code = models.CharField(max_length=2, null=True, blank=True)
    avatar_url = models.URLField(max_length=200, null=True, blank=True)
    preferred_format = models.CharField(max_length=20, choices=PlayerPreferredFormatChoices.choices, null=True, blank=True)
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField()
    last_active_at = models.DateTimeField(null=True, blank=True)
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="player_profile", null=True, blank=True)
    achievements = models.ManyToManyField("Achievement", through="PlayerAchievement", related_name="+")
    friends = models.ManyToManyField("Player", through="Friendship", related_name="+")

    class Meta:
        verbose_name = "Player"
        verbose_name_plural = "Players"
        ordering = ["-id"]

    def __str__(self):
        return str(self.display_name)

    # ── Business operations ──────────────────────────────────────────

    def promote(self):
        raise NotImplementedError("promote not implemented")

    def demote(self):
        raise NotImplementedError("demote not implemented")

    def record_win(self):
        raise NotImplementedError("record_win not implemented")

    def record_loss(self):
        raise NotImplementedError("record_loss not implemented")

    def win_rate(self):
        raise NotImplementedError("win_rate not implemented")

    def verify(self):
        raise NotImplementedError("verify not implemented")

    def update_rating(self, delta):
        raise NotImplementedError("update_rating not implemented")

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.rating is None or (self.rating >= 0 and self.rating <= 9999))):
            errors["rating_range"] = "Rating must be between 0 and 9999"
        if not ((self.peak_rating is None or self.peak_rating >= self.rating)):
            errors["peak_rating_gte_rating"] = "Peak rating must be greater than or equal to current rating"
        if not (self.display_name is not None):
            errors["display_name_not_empty"] = "Display name must not be empty"
        if errors:
            raise ValidationError(errors)


class PlayerSeasonStatsHighestRankChoices(models.TextChoices):
    BRONZE = "Bronze", "Bronze"
    SILVER = "Silver", "Silver"
    GOLD = "Gold", "Gold"
    PLATINUM = "Platinum", "Platinum"
    DIAMOND = "Diamond", "Diamond"
    MASTER = "Master", "Master"
    GRANDMASTER = "Grandmaster", "Grandmaster"


class PlayerSeasonStats(models.Model):
    wins = models.IntegerField(default=0)
    losses = models.IntegerField(default=0)
    draws = models.IntegerField(default=0)
    tournament_wins = models.IntegerField(default=0)
    highest_rank = models.CharField(max_length=20, choices=PlayerSeasonStatsHighestRankChoices.choices, null=True, blank=True)
    season_points = models.IntegerField(default=0)
    player = models.ForeignKey("Player", on_delete=models.CASCADE, null=True, blank=True)
    season = models.ForeignKey("tournaments.Season", on_delete=models.CASCADE, related_name="player_stats")

    class Meta:
        verbose_name = "Player Season Stats"
        verbose_name_plural = "Player Season Statses"
        ordering = ["-id"]

    def __str__(self):
        return str(self.wins)

    # ── Business operations ──────────────────────────────────────────

    def win_rate(self):
        raise NotImplementedError("win_rate not implemented")

    def add_points(self, points):
        raise NotImplementedError("add_points not implemented")

    def record_tournament_win(self):
        raise NotImplementedError("record_tournament_win not implemented")


class PlayerCollectionConditionChoices(models.TextChoices):
    MINT = "Mint", "Mint"
    NEARMINT = "NearMint", "Nearmint"
    EXCELLENT = "Excellent", "Excellent"
    GOOD = "Good", "Good"
    PLAYED = "Played", "Played"


class PlayerCollectionAcquiredViaChoices(models.TextChoices):
    PURCHASE = "Purchase", "Purchase"
    TRADE = "Trade", "Trade"
    TOURNAMENTREWARD = "TournamentReward", "Tournamentreward"
    PACK = "Pack", "Pack"
    CRAFT = "Craft", "Craft"


class PlayerCollection(models.Model):
    quantity = models.IntegerField(default=1)
    foil = models.BooleanField(default=False)
    condition = models.CharField(max_length=20, choices=PlayerCollectionConditionChoices.choices, default=PlayerCollectionConditionChoices.MINT)
    acquired_at = models.DateTimeField()
    acquired_via = models.CharField(max_length=20, choices=PlayerCollectionAcquiredViaChoices.choices, default=PlayerCollectionAcquiredViaChoices.PURCHASE)
    player = models.ForeignKey("Player", on_delete=models.CASCADE, related_name="collection")
    card = models.ForeignKey("cards.Card", on_delete=models.CASCADE, related_name="player_collections")

    class Meta:
        verbose_name = "Player Collection"
        verbose_name_plural = "Player Collections"
        ordering = ["-id"]

    def __str__(self):
        return str(self.quantity)

    # ── Business operations ──────────────────────────────────────────

    def add(self, quantity):
        raise NotImplementedError("add not implemented")

    def remove(self, quantity):
        raise NotImplementedError("remove not implemented")

    def estimated_value(self):
        raise NotImplementedError("estimated_value not implemented")


class FriendshipStatusChoices(models.TextChoices):
    PENDING = "Pending", "Pending"
    ACCEPTED = "Accepted", "Accepted"
    BLOCKED = "Blocked", "Blocked"


class Friendship(models.Model):
    status = models.CharField(max_length=20, choices=FriendshipStatusChoices.choices, default=FriendshipStatusChoices.PENDING)
    created_at = models.DateTimeField()
    requester = models.ForeignKey("Player", on_delete=models.CASCADE, related_name="sent_friend_requests")
    receiver = models.ForeignKey("Player", on_delete=models.CASCADE, related_name="received_friend_requests")

    class Meta:
        verbose_name = "Friendship"
        verbose_name_plural = "Friendships"
        ordering = ["-id"]

    def __str__(self):
        return str(self.status)

    # ── Business operations ──────────────────────────────────────────

    def accept(self):
        raise NotImplementedError("accept not implemented")

    def decline(self):
        raise NotImplementedError("decline not implemented")

    def block(self):
        raise NotImplementedError("block not implemented")


class AchievementRarityChoices(models.TextChoices):
    COMMON = "Common", "Common"
    UNCOMMON = "Uncommon", "Uncommon"
    RARE = "Rare", "Rare"
    EPIC = "Epic", "Epic"
    LEGENDARY = "Legendary", "Legendary"


class Achievement(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField()
    icon_url = models.URLField(max_length=200, null=True, blank=True)
    points = models.IntegerField(default=10)
    rarity = models.CharField(max_length=20, choices=AchievementRarityChoices.choices, default=AchievementRarityChoices.COMMON)
    is_hidden = models.BooleanField(default=False)

    class Meta:
        verbose_name = "Achievement"
        verbose_name_plural = "Achievements"
        ordering = ["-id"]

    def __str__(self):
        return str(self.name)


class PlayerAchievement(models.Model):
    earned_at = models.DateTimeField()
    progress = models.IntegerField(default=0)
    is_completed = models.BooleanField(default=False)
    player = models.ForeignKey("Player", on_delete=models.CASCADE, related_name="achievement_records")
    achievement = models.ForeignKey("Achievement", on_delete=models.CASCADE, related_name="player_records")

    class Meta:
        verbose_name = "Player Achievement"
        verbose_name_plural = "Player Achievements"
        ordering = ["-id"]

    def __str__(self):
        return str(self.earned_at)


class CraftingRecipe(models.Model):
    dust_cost = models.IntegerField()
    is_available = models.BooleanField(default=True)
    result_card = models.ForeignKey("cards.Card", on_delete=models.CASCADE, related_name="crafting_recipes")
    required_cards = models.ManyToManyField("cards.Card", through="CraftingIngredient")

    class Meta:
        verbose_name = "Crafting Recipe"
        verbose_name_plural = "Crafting Recipes"
        ordering = ["-id"]

    def __str__(self):
        return str(self.dust_cost)

    # ── Business operations ──────────────────────────────────────────

    def disable(self):
        raise NotImplementedError("disable not implemented")

    def enable(self):
        raise NotImplementedError("enable not implemented")


class CraftingIngredient(models.Model):
    quantity = models.IntegerField(default=1)
    recipe = models.ForeignKey("CraftingRecipe", on_delete=models.CASCADE, related_name="ingredients")
    card = models.ForeignKey("cards.Card", on_delete=models.CASCADE, related_name="used_in_recipes")

    class Meta:
        verbose_name = "Crafting Ingredient"
        verbose_name_plural = "Crafting Ingredients"
        ordering = ["-id"]

    def __str__(self):
        return str(self.quantity)
