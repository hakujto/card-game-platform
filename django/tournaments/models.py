from django.conf import settings
from django.db import models
from django.db.models.signals import pre_save, post_save, pre_delete, post_delete
from django.dispatch import receiver


class SeasonFormatChoices(models.TextChoices):
    STANDARD = "Standard", "Standard"
    EXTENDED = "Extended", "Extended"
    LEGACY = "Legacy", "Legacy"
    VINTAGE = "Vintage", "Vintage"
    COMMANDER = "Commander", "Commander"
    DRAFT = "Draft", "Draft"


class Season(models.Model):
    name = models.CharField(max_length=200)
    start_date = models.DateField()
    end_date = models.DateField()
    format = models.CharField(max_length=20, choices=SeasonFormatChoices.choices, default=SeasonFormatChoices.STANDARD)
    is_active = models.BooleanField(default=False)
    reward_description = models.TextField(null=True, blank=True)

    class Meta:
        verbose_name = "Season"
        verbose_name_plural = "Seasons"
        ordering = ["-id"]

    def __str__(self):
        return str(self.name)

    # ── Business operations ──────────────────────────────────────────

    def activate(self):
        # TODO: implement activate
        pass

    def deactivate(self):
        # TODO: implement deactivate
        pass

    def finalize_rewards(self):
        # TODO: implement finalize_rewards
        pass

    def is_ongoing(self):
        # TODO: implement is_ongoing
        return None

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.end_date is None or (self.start_date is not None and self.end_date > self.start_date))):
            errors["end_date_after_start_date"] = "Season end date must be after start date"
        if errors:
            raise ValidationError(errors)


class TournamentStatusChoices(models.TextChoices):
    DRAFT = "Draft", "Draft"
    REGISTRATION = "Registration", "Registration"
    ONGOING = "Ongoing", "Ongoing"
    COMPLETED = "Completed", "Completed"
    CANCELLED = "Cancelled", "Cancelled"


class TournamentFormatChoices(models.TextChoices):
    STANDARD = "Standard", "Standard"
    EXTENDED = "Extended", "Extended"
    LEGACY = "Legacy", "Legacy"
    VINTAGE = "Vintage", "Vintage"
    COMMANDER = "Commander", "Commander"
    DRAFT = "Draft", "Draft"


class TournamentTournamentTypeChoices(models.TextChoices):
    SWISS = "Swiss", "Swiss"
    SINGLEELIMINATION = "SingleElimination", "Singleelimination"
    DOUBLEELIMINATION = "DoubleElimination", "Doubleelimination"
    ROUNDROBIN = "RoundRobin", "Roundrobin"


class Tournament(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=TournamentStatusChoices.choices, default=TournamentStatusChoices.DRAFT)
    format = models.CharField(max_length=20, choices=TournamentFormatChoices.choices, default=TournamentFormatChoices.STANDARD)
    tournament_type = models.CharField(max_length=20, choices=TournamentTournamentTypeChoices.choices, default=TournamentTournamentTypeChoices.SWISS)
    max_players = models.IntegerField()
    entry_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    prize_pool = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    start_time = models.DateTimeField()
    end_time = models.DateTimeField(null=True, blank=True)
    is_online = models.BooleanField(default=True)
    location = models.CharField(max_length=300, null=True, blank=True)
    rules_text = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField()
    season = models.ForeignKey("Season", on_delete=models.CASCADE, related_name="tournaments")
    organizer = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="organized_tournaments")
    judges = models.ManyToManyField("players.Player", through="TournamentJudge", related_name="+")

    class Meta:
        verbose_name = "Tournament"
        verbose_name_plural = "Tournaments"
        ordering = ["-id"]

    def __str__(self):
        return str(self.name)

    # ── Business operations ──────────────────────────────────────────

    def start(self):
        # TODO: implement start
        pass

    def cancel(self):
        # TODO: implement cancel
        pass

    def complete(self):
        # TODO: implement complete
        pass

    def generate_round(self):
        # TODO: implement generate_round
        pass

    def calculate_prize_distribution(self):
        # TODO: implement calculate_prize_distribution
        return None

    def register_player(self, player_id, deck_id):
        # TODO: implement register_player
        pass

    def is_full(self):
        # TODO: implement is_full
        return None

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.max_players is None or (self.max_players >= 2 and self.max_players <= 512))):
            errors["max_players_positive"] = "Tournament must allow between 2 and 512 players"
        if not ((self.entry_fee is None or self.entry_fee >= 0)):
            errors["entry_fee_not_negative"] = "Entry fee must not be negative"
        if not ((self.prize_pool is None or self.prize_pool >= 0)):
            errors["prize_pool_not_negative"] = "Prize pool must not be negative"
        if errors:
            raise ValidationError(errors)

    def validate_implies(self):
        from django.core.exceptions import ValidationError
        if (self.end_time is not None) and (not ((self.end_time is None or (self.start_time is not None and self.end_time > self.start_time)))):
            raise ValidationError({"end_time_after_start": "End time must be after start time"})

    # ── Lifecycle state machine ──────────────────────────────────────
    ALLOWED_TRANSITIONS = {
        "Draft": ["Registration"],
        "Registration": ["Ongoing", "Cancelled"],
        "Ongoing": ["Completed", "Cancelled"],
    }

    def assert_transition(self, to_state):
        from django.core.exceptions import ValidationError
        allowed = self.ALLOWED_TRANSITIONS.get(self.status, [])
        if to_state not in allowed:
            raise ValidationError(f"Transition {self.status} -> {to_state} not allowed")

    # ── Lifecycle hooks ──────────────────────────────────────────────

    def _hook_sync_season_stats(self, **kwargs):
        # TODO: implement sync_season_stats
        pass


class TournamentJudgeRoleChoices(models.TextChoices):
    HEADJUDGE = "HeadJudge", "Headjudge"
    JUDGE = "Judge", "Judge"
    SCOREKEEPERJUDGE = "ScorekeeperJudge", "Scorekeeperjudge"


class TournamentJudge(models.Model):
    role = models.CharField(max_length=20, choices=TournamentJudgeRoleChoices.choices, default=TournamentJudgeRoleChoices.JUDGE)
    tournament = models.ForeignKey("Tournament", on_delete=models.CASCADE, related_name="judge_assignments")
    player = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="judge_roles")

    class Meta:
        verbose_name = "Tournament Judge"
        verbose_name_plural = "Tournament Judges"
        ordering = ["-id"]

    def __str__(self):
        return str(self.role)

    # ── Business operations ──────────────────────────────────────────

    def promote_to_head(self):
        # TODO: implement promote_to_head
        pass

    def remove(self):
        # TODO: implement remove
        pass


class TournamentRegistrationStatusChoices(models.TextChoices):
    REGISTERED = "Registered", "Registered"
    WAITLISTED = "Waitlisted", "Waitlisted"
    WITHDRAWN = "Withdrawn", "Withdrawn"
    DISQUALIFIED = "Disqualified", "Disqualified"


class TournamentRegistration(models.Model):
    status = models.CharField(max_length=20, choices=TournamentRegistrationStatusChoices.choices, default=TournamentRegistrationStatusChoices.REGISTERED)
    seed = models.IntegerField(null=True, blank=True)
    final_standing = models.IntegerField(null=True, blank=True)
    points_earned = models.IntegerField(default=0)
    registered_at = models.DateTimeField()
    tournament = models.ForeignKey("Tournament", on_delete=models.CASCADE)
    player = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="tournament_registrations")
    deck = models.ForeignKey("cards.Deck", on_delete=models.CASCADE, related_name="tournament_registrations")

    class Meta:
        verbose_name = "Tournament Registration"
        verbose_name_plural = "Tournament Registrations"
        ordering = ["-id"]

    def __str__(self):
        return str(self.status)

    # ── Business operations ──────────────────────────────────────────

    def withdraw(self):
        # TODO: implement withdraw
        pass

    def disqualify(self, reason):
        # TODO: implement disqualify
        pass

    def promote_from_waitlist(self):
        # TODO: implement promote_from_waitlist
        pass

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.points_earned is None or self.points_earned >= 0)):
            errors["points_earned_not_negative"] = "Points earned must not be negative"
        if errors:
            raise ValidationError(errors)

    def validate_implies(self):
        from django.core.exceptions import ValidationError
        if (self.final_standing is not None) and (not ((self.final_standing is None or self.final_standing > 0))):
            raise ValidationError({"final_standing_positive": "Final standing must be greater than zero"})
        if (self.seed is not None) and (not ((self.seed is None or self.seed > 0))):
            raise ValidationError({"seed_positive": "Seed must be greater than zero"})


class TournamentRoundStatusChoices(models.TextChoices):
    PENDING = "Pending", "Pending"
    ACTIVE = "Active", "Active"
    COMPLETED = "Completed", "Completed"


class TournamentRound(models.Model):
    round_number = models.IntegerField()
    status = models.CharField(max_length=20, choices=TournamentRoundStatusChoices.choices, default=TournamentRoundStatusChoices.PENDING)
    started_at = models.DateTimeField(null=True, blank=True)
    ended_at = models.DateTimeField(null=True, blank=True)
    time_limit_minutes = models.IntegerField(default=50)
    tournament = models.ForeignKey("Tournament", on_delete=models.CASCADE)

    class Meta:
        verbose_name = "Tournament Round"
        verbose_name_plural = "Tournament Rounds"
        ordering = ["-id"]

    def __str__(self):
        return str(self.round_number)

    # ── Business operations ──────────────────────────────────────────

    def start(self):
        # TODO: implement start
        pass

    def complete(self):
        # TODO: implement complete
        pass

    def generate_pairings(self):
        # TODO: implement generate_pairings
        pass

    def is_time_expired(self):
        # TODO: implement is_time_expired
        return None

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.round_number is None or self.round_number > 0)):
            errors["round_number_positive"] = "Round number must be greater than zero"
        if not ((self.time_limit_minutes is None or self.time_limit_minutes > 0)):
            errors["time_limit_positive"] = "Round time limit must be greater than zero"
        if errors:
            raise ValidationError(errors)

    def validate_implies(self):
        from django.core.exceptions import ValidationError
        if (self.ended_at is not None) and (not ((self.ended_at is None or (self.started_at is not None and self.ended_at > self.started_at)))):
            raise ValidationError({"ended_after_started": "Round end time must be after start time"})
        if (self.status == TournamentRoundStatusChoices.COMPLETED) and (self.started_at is None):
            raise ValidationError({"completed_requires_started_at": "Completed round must have a start time"})


class MatchStatusChoices(models.TextChoices):
    PENDING = "Pending", "Pending"
    ACTIVE = "Active", "Active"
    COMPLETED = "Completed", "Completed"
    BYE = "BYE", "Bye"
    DRAW = "Draw", "Draw"


class Match(models.Model):
    table_number = models.IntegerField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=MatchStatusChoices.choices, default=MatchStatusChoices.PENDING)
    player1_wins = models.IntegerField(default=0)
    player2_wins = models.IntegerField(default=0)
    started_at = models.DateTimeField(null=True, blank=True)
    ended_at = models.DateTimeField(null=True, blank=True)
    result_notes = models.TextField(null=True, blank=True)
    round = models.ForeignKey("TournamentRound", on_delete=models.CASCADE, null=True, blank=True)
    player1 = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="matches_as_player1")
    player2 = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="matches_as_player2", null=True, blank=True)

    class Meta:
        verbose_name = "Match"
        verbose_name_plural = "Matches"
        ordering = ["-id"]

    def __str__(self):
        return str(self.table_number)

    # ── Business operations ──────────────────────────────────────────

    def record_result(self, p1_wins, p2_wins):
        # TODO: implement record_result
        pass

    def finalize_result(self):
        # TODO: implement finalize_result
        pass

    def determine_winner(self):
        # TODO: implement determine_winner
        return None

    def concede(self, player_id):
        # TODO: implement concede
        pass

    def draw(self):
        # TODO: implement draw
        pass

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not (((self.player1_wins is None or self.player1_wins >= 0) and (self.player2_wins is None or self.player2_wins >= 0))):
            errors["wins_not_negative"] = "Win counts must not be negative"
        if not (((self.player1_wins is None or (self.player1_wins >= 0 and self.player1_wins <= 2)) and (self.player2_wins is None or (self.player2_wins >= 0 and self.player2_wins <= 2)))):
            errors["max_three_games"] = "Win counts cannot exceed 2 in a best-of-3 match"
        if errors:
            raise ValidationError(errors)

    def validate_implies(self):
        from django.core.exceptions import ValidationError
        if (self.status == MatchStatusChoices.BYE) and (self.player2 is not None):
            raise ValidationError({"bye_has_no_player2": "BYE match must not have a second player"})
        if (self.ended_at is not None) and (not ((self.ended_at is None or (self.started_at is not None and self.ended_at > self.started_at)))):
            raise ValidationError({"ended_after_started": "Match end time must be after start time"})
        if (self.status == MatchStatusChoices.COMPLETED) and (self.started_at is None):
            raise ValidationError({"completed_requires_started_at": "Completed match must have a start time"})

    # ── Lifecycle state machine ──────────────────────────────────────
    ALLOWED_TRANSITIONS = {
        "Pending": ["Active", "BYE"],
        "Active": ["Completed", "Draw"],
    }

    def assert_transition(self, to_state):
        from django.core.exceptions import ValidationError
        allowed = self.ALLOWED_TRANSITIONS.get(self.status, [])
        if to_state not in allowed:
            raise ValidationError(f"Transition {self.status} -> {to_state} not allowed")


class GameWinnerSideChoices(models.TextChoices):
    PLAYER1 = "Player1", "Player1"
    PLAYER2 = "Player2", "Player2"
    DRAW = "Draw", "Draw"


class GameEndedByChoices(models.TextChoices):
    NORMAL = "Normal", "Normal"
    TIMEOUT = "Timeout", "Timeout"
    CONCESSION = "Concession", "Concession"
    DRAWOFFER = "DrawOffer", "Drawoffer"


class Game(models.Model):
    game_number = models.IntegerField()
    winner_side = models.CharField(max_length=20, choices=GameWinnerSideChoices.choices, null=True, blank=True)
    turns_played = models.IntegerField(null=True, blank=True)
    duration_seconds = models.IntegerField(null=True, blank=True)
    ended_by = models.CharField(max_length=20, choices=GameEndedByChoices.choices, null=True, blank=True)
    replay_url = models.URLField(max_length=200, null=True, blank=True)
    match = models.ForeignKey("Match", on_delete=models.CASCADE)
    winner = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="won_games", null=True, blank=True)

    class Meta:
        verbose_name = "Game"
        verbose_name_plural = "Games"
        ordering = ["-id"]

    def __str__(self):
        return str(self.game_number)

    # ── Business operations ──────────────────────────────────────────

    def record_winner(self, winner_side):
        # TODO: implement record_winner
        pass

    def duration_minutes(self):
        # TODO: implement duration_minutes
        return None

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.game_number is None or (self.game_number >= 1 and self.game_number <= 3))):
            errors["game_number_range"] = "Game number must be between 1 and 3 (best-of-3)"
        if errors:
            raise ValidationError(errors)

    def validate_implies(self):
        from django.core.exceptions import ValidationError
        if (self.turns_played is not None) and (not ((self.turns_played is None or self.turns_played > 0))):
            raise ValidationError({"turns_played_positive": "Turns played must be greater than zero"})
        if (self.duration_seconds is not None) and (not ((self.duration_seconds is None or self.duration_seconds > 0))):
            raise ValidationError({"duration_positive": "Game duration must be greater than zero"})
        if (self.winner_side == GameWinnerSideChoices.DRAW) and (self.winner is not None):
            raise ValidationError({"draw_has_no_winner": "A draw cannot have a winner"})
        if ((self.winner_side is not None and self.winner_side != GameWinnerSideChoices.DRAW)) and (self.winner is None):
            raise ValidationError({"non_draw_requires_winner": "A decisive game must have a winner player set"})


class TournamentPrizePrizeTypeChoices(models.TextChoices):
    CURRENCY = "Currency", "Currency"
    CARDS = "Cards", "Cards"
    BOOSTERPACKS = "BoosterPacks", "Boosterpacks"
    TROPHY = "Trophy", "Trophy"
    SEASONPOINTS = "SeasonPoints", "Seasonpoints"
    MIXED = "Mixed", "Mixed"


class TournamentPrize(models.Model):
    placement_from = models.IntegerField()
    placement_to = models.IntegerField()
    prize_type = models.CharField(max_length=20, choices=TournamentPrizePrizeTypeChoices.choices)
    amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    description = models.TextField(null=True, blank=True)
    packs_count = models.IntegerField(null=True, blank=True)
    season_points = models.IntegerField(default=0)
    tournament = models.ForeignKey("Tournament", on_delete=models.CASCADE)

    class Meta:
        verbose_name = "Tournament Prize"
        verbose_name_plural = "Tournament Prizes"
        ordering = ["-id"]

    def __str__(self):
        return str(self.placement_from)

    # ── Business operations ──────────────────────────────────────────

    def applies_to_placement(self, placement):
        # TODO: implement applies_to_placement
        return None

    def award_to_player(self, player_id):
        # TODO: implement award_to_player
        pass

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.placement_to is None or (self.placement_from is not None and self.placement_to >= self.placement_from))):
            errors["placement_range_valid"] = "placement_to must be greater than or equal to placement_from"
        if not ((self.placement_from is None or self.placement_from > 0)):
            errors["placement_from_positive"] = "placement_from must be greater than zero"
        if not ((self.amount is None or self.amount >= 0)):
            errors["amount_not_negative"] = "Prize amount must not be negative"
        if errors:
            raise ValidationError(errors)


class AwardedPrize(models.Model):
    final_placement = models.IntegerField()
    awarded_at = models.DateTimeField()
    claimed = models.BooleanField(default=False)
    claimed_at = models.DateTimeField(null=True, blank=True)
    prize = models.ForeignKey("TournamentPrize", on_delete=models.CASCADE, related_name="awarded_prizes")
    player = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="awarded_prizes")

    class Meta:
        verbose_name = "Awarded Prize"
        verbose_name_plural = "Awarded Prizes"
        ordering = ["-id"]

    def __str__(self):
        return str(self.final_placement)

    # ── Business operations ──────────────────────────────────────────

    def claim(self):
        # TODO: implement claim
        pass

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.final_placement is None or self.final_placement > 0)):
            errors["final_placement_positive"] = "Final placement must be greater than zero"
        if errors:
            raise ValidationError(errors)

    def validate_implies(self):
        from django.core.exceptions import ValidationError
        if (self.claimed is True) and (self.claimed_at is None):
            raise ValidationError({"claimed_requires_claimed_at": "Claimed prize must have a claimed_at timestamp"})



# ── Signal receivers ─────────────────────────────────────────────────────

@receiver(post_save, sender=Tournament)
def _tournament_sync_season_stats(sender, instance, **kwargs):
    if not kwargs.get("created"):
        instance._hook_sync_season_stats(**kwargs)
