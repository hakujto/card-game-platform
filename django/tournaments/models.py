from django.conf import settings
from django.db import models


class FormatChoices(models.TextChoices):
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
    format = models.CharField(max_length=20, choices=FormatChoices.choices, default=FormatChoices.STANDARD)
    is_active = models.BooleanField(default=False)
    reward_description = models.TextField(null=True, blank=True)

    class Meta:
        verbose_name = "Season"
        verbose_name_plural = "Seasons"
        ordering = ["-id"]

    def __str__(self):
        return str(self.name)


class FormatChoices(models.TextChoices):
    STANDARD = "Standard", "Standard"
    EXTENDED = "Extended", "Extended"
    LEGACY = "Legacy", "Legacy"
    VINTAGE = "Vintage", "Vintage"
    COMMANDER = "Commander", "Commander"
    DRAFT = "Draft", "Draft"


class TournamentTypeChoices(models.TextChoices):
    SWISS = "Swiss", "Swiss"
    SINGLEELIMINATION = "SingleElimination", "Singleelimination"
    DOUBLEELIMINATION = "DoubleElimination", "Doubleelimination"
    ROUNDROBIN = "RoundRobin", "Roundrobin"


class StatusChoices(models.TextChoices):
    DRAFT = "Draft", "Draft"
    REGISTRATION = "Registration", "Registration"
    ONGOING = "Ongoing", "Ongoing"
    COMPLETED = "Completed", "Completed"
    CANCELLED = "Cancelled", "Cancelled"


class Tournament(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(null=True, blank=True)
    format = models.CharField(max_length=20, choices=FormatChoices.choices, default=FormatChoices.STANDARD)
    tournament_type = models.CharField(max_length=20, choices=TournamentTypeChoices.choices, default=TournamentTypeChoices.SWISS)
    status = models.CharField(max_length=20, choices=StatusChoices.choices, default=StatusChoices.DRAFT)
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


class RoleChoices(models.TextChoices):
    HEADJUDGE = "HeadJudge", "Headjudge"
    JUDGE = "Judge", "Judge"
    SCOREKEEPERJUDGE = "ScorekeeperJudge", "Scorekeeperjudge"


class TournamentJudge(models.Model):
    role = models.CharField(max_length=20, choices=RoleChoices.choices, default=RoleChoices.JUDGE)
    tournament = models.ForeignKey("Tournament", on_delete=models.CASCADE, related_name="judge_assignments")
    player = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="judge_roles")

    class Meta:
        verbose_name = "Tournament Judge"
        verbose_name_plural = "Tournament Judges"
        ordering = ["-id"]

    def __str__(self):
        return str(self.role)


class StatusChoices(models.TextChoices):
    REGISTERED = "Registered", "Registered"
    WAITLISTED = "Waitlisted", "Waitlisted"
    WITHDRAWN = "Withdrawn", "Withdrawn"
    DISQUALIFIED = "Disqualified", "Disqualified"


class TournamentRegistration(models.Model):
    status = models.CharField(max_length=20, choices=StatusChoices.choices, default=StatusChoices.REGISTERED)
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


class StatusChoices(models.TextChoices):
    PENDING = "Pending", "Pending"
    ACTIVE = "Active", "Active"
    COMPLETED = "Completed", "Completed"


class TournamentRound(models.Model):
    round_number = models.IntegerField()
    status = models.CharField(max_length=20, choices=StatusChoices.choices, default=StatusChoices.PENDING)
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


class StatusChoices(models.TextChoices):
    PENDING = "Pending", "Pending"
    ACTIVE = "Active", "Active"
    COMPLETED = "Completed", "Completed"
    BYE = "BYE", "Bye"
    DRAW = "Draw", "Draw"


class Match(models.Model):
    table_number = models.IntegerField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=StatusChoices.choices, default=StatusChoices.PENDING)
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


class WinnerSideChoices(models.TextChoices):
    PLAYER1 = "Player1", "Player1"
    PLAYER2 = "Player2", "Player2"
    DRAW = "Draw", "Draw"


class EndedByChoices(models.TextChoices):
    NORMAL = "Normal", "Normal"
    TIMEOUT = "Timeout", "Timeout"
    CONCESSION = "Concession", "Concession"
    DRAWOFFER = "DrawOffer", "Drawoffer"


class Game(models.Model):
    game_number = models.IntegerField()
    winner_side = models.CharField(max_length=20, choices=WinnerSideChoices.choices, null=True, blank=True)
    turns_played = models.IntegerField(null=True, blank=True)
    duration_seconds = models.IntegerField(null=True, blank=True)
    ended_by = models.CharField(max_length=20, choices=EndedByChoices.choices, null=True, blank=True)
    replay_url = models.URLField(max_length=200, null=True, blank=True)
    match = models.ForeignKey("Match", on_delete=models.CASCADE)
    winner = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="won_games", null=True, blank=True)

    class Meta:
        verbose_name = "Game"
        verbose_name_plural = "Games"
        ordering = ["-id"]

    def __str__(self):
        return str(self.game_number)


class PrizeTypeChoices(models.TextChoices):
    CURRENCY = "Currency", "Currency"
    CARDS = "Cards", "Cards"
    BOOSTERPACKS = "BoosterPacks", "Boosterpacks"
    TROPHY = "Trophy", "Trophy"
    SEASONPOINTS = "SeasonPoints", "Seasonpoints"
    MIXED = "Mixed", "Mixed"


class TournamentPrize(models.Model):
    placement_from = models.IntegerField()
    placement_to = models.IntegerField()
    prize_type = models.CharField(max_length=20, choices=PrizeTypeChoices.choices)
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
