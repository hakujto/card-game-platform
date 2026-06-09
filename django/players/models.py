from django.conf import settings
from django.db import models
from django.db.models.signals import pre_save, post_save, pre_delete, post_delete
from django.dispatch import receiver


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
    display_name = models.CharField(max_length=50, unique=True)
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
        # TODO: implement promote
        return None

    def demote(self):
        # TODO: implement demote
        return None

    def record_win(self):
        # TODO: implement record_win
        pass

    def record_loss(self):
        # TODO: implement record_loss
        pass

    def win_rate(self):
        # TODO: implement win_rate
        return None

    def verify(self):
        # TODO: implement verify
        pass

    def update_rating(self, delta):
        # TODO: implement update_rating
        pass

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.rating is None or (self.rating >= 0 and self.rating <= 9999))):
            errors["rating_range"] = "Rating must be between 0 and 9999"
        if not ((self.peak_rating is None or (self.rating is not None and self.peak_rating >= self.rating))):
            errors["peak_rating_gte_rating"] = "Peak rating must be greater than or equal to current rating"
        if not (self.display_name is not None):
            errors["display_name_not_empty"] = "Display name must not be empty"
        if errors:
            raise ValidationError(errors)

    # ── Lifecycle hooks ──────────────────────────────────────────────

    def _hook_initialize_collection(self, **kwargs):
        # TODO: implement initialize_collection
        pass

    def _hook_update_rank(self, **kwargs):
        # TODO: implement update_rank
        pass


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
        # TODO: implement win_rate
        return None

    def add_points(self, points):
        # TODO: implement add_points
        pass

    def record_tournament_win(self):
        # TODO: implement record_tournament_win
        pass

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.wins is None or self.wins >= 0)):
            errors["wins_not_negative"] = "Season wins must not be negative"
        if not ((self.losses is None or self.losses >= 0)):
            errors["losses_not_negative"] = "Season losses must not be negative"
        if not ((self.tournament_wins is None or self.tournament_wins >= 0)):
            errors["tournament_wins_not_negative"] = "Season tournament wins must not be negative"
        if not ((self.season_points is None or self.season_points >= 0)):
            errors["season_points_not_negative"] = "Season points must not be negative"
        if errors:
            raise ValidationError(errors)


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
    card = models.ForeignKey("cards.Card", on_delete=models.PROTECT, related_name="player_collections")

    class Meta:
        verbose_name = "Player Collection"
        verbose_name_plural = "Player Collections"
        ordering = ["-id"]

    def __str__(self):
        return str(self.quantity)

    # ── Business operations ──────────────────────────────────────────

    def add(self, quantity):
        # TODO: implement add
        pass

    def remove(self, quantity):
        # TODO: implement remove
        pass

    def estimated_value(self):
        # TODO: implement estimated_value
        return None

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.quantity is None or self.quantity > 0)):
            errors["quantity_positive"] = "Collection quantity must be greater than zero"
        if errors:
            raise ValidationError(errors)


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
        # TODO: implement accept
        pass

    def decline(self):
        # TODO: implement decline
        pass

    def block(self):
        # TODO: implement block
        pass


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

    # ── Business operations ──────────────────────────────────────────

    def point_value(self, multiplier):
        # TODO: implement point_value
        return None

    def reveal(self):
        # TODO: implement reveal
        pass

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.points is None or self.points > 0)):
            errors["points_positive"] = "Achievement must award at least one point"
        if errors:
            raise ValidationError(errors)


class PlayerAchievement(models.Model):
    earned_at = models.DateTimeField()
    progress = models.IntegerField(default=0)
    is_completed = models.BooleanField(default=False)
    player = models.ForeignKey("Player", on_delete=models.CASCADE, related_name="achievement_records")
    achievement = models.ForeignKey("Achievement", on_delete=models.PROTECT, related_name="player_records")

    class Meta:
        verbose_name = "Player Achievement"
        verbose_name_plural = "Player Achievements"
        ordering = ["-id"]

    def __str__(self):
        return str(self.earned_at)

    # ── Business operations ──────────────────────────────────────────

    def increment_progress(self, amount):
        # TODO: implement increment_progress
        pass

    def complete(self):
        # TODO: implement complete
        pass

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.progress is None or self.progress >= 0)):
            errors["progress_not_negative"] = "Achievement progress must not be negative"
        if errors:
            raise ValidationError(errors)

    def validate_implies(self):
        from django.core.exceptions import ValidationError
        if (self.is_completed is True) and (not ((self.progress is None or self.progress > 0))):
            raise ValidationError({"completed_requires_progress": "Completed achievement must have progress greater than zero"})


class CraftingRecipe(models.Model):
    dust_cost = models.IntegerField()
    is_available = models.BooleanField(default=True)
    result_card = models.ForeignKey("cards.Card", on_delete=models.PROTECT, related_name="crafting_recipes")
    required_cards = models.ManyToManyField("cards.Card", through="CraftingIngredient")

    class Meta:
        verbose_name = "Crafting Recipe"
        verbose_name_plural = "Crafting Recipes"
        ordering = ["-id"]

    def __str__(self):
        return str(self.dust_cost)

    # ── Business operations ──────────────────────────────────────────

    def can_craft(self, player_id):
        # TODO: implement can_craft
        return None

    def execute_craft(self, player_id):
        # TODO: implement execute_craft
        pass

    def disable(self):
        # TODO: implement disable
        pass

    def enable(self):
        # TODO: implement enable
        pass

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.dust_cost is None or self.dust_cost > 0)):
            errors["dust_cost_positive"] = "Crafting recipe must have a dust cost greater than zero"
        if errors:
            raise ValidationError(errors)


class CraftingIngredient(models.Model):
    quantity = models.IntegerField(default=1)
    recipe = models.ForeignKey("CraftingRecipe", on_delete=models.CASCADE, related_name="ingredients")
    card = models.ForeignKey("cards.Card", on_delete=models.PROTECT, related_name="used_in_recipes")

    class Meta:
        verbose_name = "Crafting Ingredient"
        verbose_name_plural = "Crafting Ingredients"
        ordering = ["-id"]

    def __str__(self):
        return str(self.quantity)



# ── Signal receivers ─────────────────────────────────────────────────────

@receiver(post_save, sender=Player)
def _player_initialize_collection(sender, instance, **kwargs):
    if kwargs.get("created"):
        instance._hook_initialize_collection(**kwargs)

@receiver(post_save, sender=Player)
def _player_update_rank(sender, instance, **kwargs):
    if not kwargs.get("created"):
        instance._hook_update_rank(**kwargs)
