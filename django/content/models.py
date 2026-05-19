from django.conf import settings
from django.db import models


class DraftSessionStatusChoices(models.TextChoices):
    WAITINGFORPLAYERS = "WaitingForPlayers", "Waitingforplayers"
    DRAFTING = "Drafting", "Drafting"
    COMPLETED = "Completed", "Completed"
    ABANDONED = "Abandoned", "Abandoned"


class DraftSessionDraftTypeChoices(models.TextChoices):
    BOOSTER = "Booster", "Booster"
    CUBE = "Cube", "Cube"
    ROCHESTER = "Rochester", "Rochester"


class DraftSession(models.Model):
    status = models.CharField(max_length=20, choices=DraftSessionStatusChoices.choices, default=DraftSessionStatusChoices.WAITINGFORPLAYERS)
    draft_type = models.CharField(max_length=20, choices=DraftSessionDraftTypeChoices.choices, default=DraftSessionDraftTypeChoices.BOOSTER)
    seats = models.IntegerField(default=8)
    time_per_pick_seconds = models.IntegerField(default=30)
    created_at = models.DateTimeField()
    completed_at = models.DateTimeField(null=True, blank=True)
    card_set = models.ForeignKey("cards.CardSet", on_delete=models.CASCADE, related_name="draft_sessions")

    class Meta:
        verbose_name = "Draft Session"
        verbose_name_plural = "Draft Sessions"
        ordering = ["-id"]

    def __str__(self):
        return str(self.status)

    # ── Business operations ──────────────────────────────────────────

    def start(self):
        # TODO: implement start
        pass

    def abandon(self):
        # TODO: implement abandon
        pass

    def complete(self):
        # TODO: implement complete
        pass

    def is_full(self):
        # TODO: implement is_full
        return None

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.seats is None or (self.seats >= 2 and self.seats <= 16))):
            errors["seats_range"] = "Draft session must have between 2 and 16 seats"
        if not ((self.time_per_pick_seconds is None or self.time_per_pick_seconds > 0)):
            errors["time_per_pick_positive"] = "Time per pick must be greater than zero"
        if errors:
            raise ValidationError(errors)

    def validate_implies(self):
        from django.core.exceptions import ValidationError
        if (self.completed_at is not None) and (not (self.status == DraftSessionStatusChoices.COMPLETED)):
            raise ValidationError({"completed_at_requires_completed_status": "completed_at can only be set when draft status is Completed"})

    # ── Lifecycle state machine ──────────────────────────────────────
    ALLOWED_TRANSITIONS = {
        "WaitingForPlayers": ["Drafting", "Abandoned"],
        "Drafting": ["Completed", "Abandoned"],
    }

    def assert_transition(self, to_state):
        from django.core.exceptions import ValidationError
        allowed = self.ALLOWED_TRANSITIONS.get(self.status, [])
        if to_state not in allowed:
            raise ValidationError(f"Transition {self.status} -> {to_state} not allowed")


class DraftParticipant(models.Model):
    seat_number = models.IntegerField()
    joined_at = models.DateTimeField()
    session = models.ForeignKey("DraftSession", on_delete=models.CASCADE, null=True, blank=True)
    player = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="draft_sessions")

    class Meta:
        verbose_name = "Draft Participant"
        verbose_name_plural = "Draft Participants"
        ordering = ["-id"]

    def __str__(self):
        return str(self.seat_number)

    # ── Business operations ──────────────────────────────────────────

    def pick_card(self, card_id, pack_number):
        # TODO: implement pick_card
        pass

    def drafted_card_count(self):
        # TODO: implement drafted_card_count
        return None

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.seat_number is None or self.seat_number > 0)):
            errors["seat_number_positive"] = "Seat number must be greater than zero"
        if errors:
            raise ValidationError(errors)


class DraftPick(models.Model):
    pick_number = models.IntegerField()
    pack_number = models.IntegerField()
    picked_at = models.DateTimeField()
    participant = models.ForeignKey("DraftParticipant", on_delete=models.CASCADE, related_name="picks")
    card = models.ForeignKey("cards.Card", on_delete=models.CASCADE, related_name="draft_picks")

    class Meta:
        verbose_name = "Draft Pick"
        verbose_name_plural = "Draft Picks"
        ordering = ["-id"]

    def __str__(self):
        return str(self.pick_number)

    # ── Business operations ──────────────────────────────────────────

    def is_first_pick(self):
        # TODO: implement is_first_pick
        return None

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.pick_number is None or self.pick_number > 0)):
            errors["pick_number_positive"] = "Pick number must be greater than zero"
        if not ((self.pack_number is None or (self.pack_number >= 1 and self.pack_number <= 3))):
            errors["pack_number_range"] = "Pack number must be between 1 and 3"
        if errors:
            raise ValidationError(errors)


class ArticleStatusChoices(models.TextChoices):
    DRAFT = "Draft", "Draft"
    PUBLISHED = "Published", "Published"
    ARCHIVED = "Archived", "Archived"


class ArticleArticleTypeChoices(models.TextChoices):
    GUIDE = "Guide", "Guide"
    TIERLIST = "Tierlist", "Tierlist"
    MATCHUP = "Matchup", "Matchup"
    NEWS = "News", "News"
    SPOTLIGHT = "Spotlight", "Spotlight"
    DECKLIST = "Decklist", "Decklist"


class ArticleLanguageChoices(models.TextChoices):
    EN = "EN", "En"
    DE = "DE", "De"
    FR = "FR", "Fr"
    IT = "IT", "It"
    ES = "ES", "Es"
    JP = "JP", "Jp"
    PT = "PT", "Pt"


class Article(models.Model):
    title = models.CharField(max_length=300)
    slug = models.CharField(max_length=300)
    body = models.TextField()
    excerpt = models.TextField(null=True, blank=True)
    cover_image_url = models.URLField(max_length=200, null=True, blank=True)
    status = models.CharField(max_length=20, choices=ArticleStatusChoices.choices, default=ArticleStatusChoices.DRAFT)
    article_type = models.CharField(max_length=20, choices=ArticleArticleTypeChoices.choices, default=ArticleArticleTypeChoices.GUIDE)
    language = models.CharField(max_length=20, choices=ArticleLanguageChoices.choices, default=ArticleLanguageChoices.EN)
    view_count = models.IntegerField(default=0)
    likes_count = models.IntegerField(default=0)
    is_featured = models.BooleanField(default=False)
    published_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    author = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="articles")
    featured_deck = models.ForeignKey("cards.Deck", on_delete=models.CASCADE, related_name="articles", null=True, blank=True)
    tags = models.ManyToManyField("ArticleTag", through="ArticleTagAssignment")

    class Meta:
        verbose_name = "Article"
        verbose_name_plural = "Articles"
        ordering = ["-id"]

    def __str__(self):
        return str(self.title)

    # ── Business operations ──────────────────────────────────────────

    def publish(self):
        # TODO: implement publish
        pass

    def archive(self):
        # TODO: implement archive
        pass

    def increment_view(self):
        # TODO: implement increment_view
        pass

    def like(self):
        # TODO: implement like
        pass

    def unlike(self):
        # TODO: implement unlike
        pass

    def reading_time_minutes(self):
        # TODO: implement reading_time_minutes
        return None

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.view_count is None or self.view_count >= 0)):
            errors["view_count_not_negative"] = "Article view count must not be negative"
        if not ((self.likes_count is None or self.likes_count >= 0)):
            errors["likes_count_not_negative"] = "Article likes count must not be negative"
        if errors:
            raise ValidationError(errors)

    def validate_implies(self):
        from django.core.exceptions import ValidationError
        if (self.status == ArticleStatusChoices.PUBLISHED) and (self.published_at is None):
            raise ValidationError({"published_requires_published_at": "Published article must have a published_at timestamp"})

    # ── Lifecycle state machine ──────────────────────────────────────
    ALLOWED_TRANSITIONS = {
        "Draft": ["Published"],
        "Published": ["Archived"],
        "Archived": ["Draft"],
    }

    def assert_transition(self, to_state):
        from django.core.exceptions import ValidationError
        allowed = self.ALLOWED_TRANSITIONS.get(self.status, [])
        if to_state not in allowed:
            raise ValidationError(f"Transition {self.status} -> {to_state} not allowed")


class ArticleTag(models.Model):
    name = models.CharField(max_length=100)
    slug = models.CharField(max_length=100)

    class Meta:
        verbose_name = "Article Tag"
        verbose_name_plural = "Article Tags"
        ordering = ["-id"]

    def __str__(self):
        return str(self.name)

    # ── Business operations ──────────────────────────────────────────

    def rename(self, new_name):
        # TODO: implement rename
        pass

    def article_count(self):
        # TODO: implement article_count
        return None


class ArticleTagAssignment(models.Model):
    article = models.ForeignKey("Article", on_delete=models.CASCADE, related_name="tag_assignments")
    tag = models.ForeignKey("ArticleTag", on_delete=models.CASCADE, related_name="article_assignments")

    class Meta:
        verbose_name = "Article Tag Assignment"
        verbose_name_plural = "Article Tag Assignments"
        ordering = ["-id"]

    def __str__(self):
        return str(self.id)


class ArticleComment(models.Model):
    body = models.TextField()
    is_hidden = models.BooleanField(default=False)
    created_at = models.DateTimeField()
    article = models.ForeignKey("Article", on_delete=models.CASCADE, null=True, blank=True)
    author = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="article_comments")
    parent_comment = models.ForeignKey("ArticleComment", on_delete=models.CASCADE, related_name="replies", null=True, blank=True)

    class Meta:
        verbose_name = "Article Comment"
        verbose_name_plural = "Article Comments"
        ordering = ["-id"]

    def __str__(self):
        return str(self.body)

    # ── Business operations ──────────────────────────────────────────

    def hide(self):
        # TODO: implement hide
        pass

    def unhide(self):
        # TODO: implement unhide
        pass

    def is_reply(self):
        # TODO: implement is_reply
        return None


class StreamStatusChoices(models.TextChoices):
    SCHEDULED = "Scheduled", "Scheduled"
    LIVE = "Live", "Live"
    ENDED = "Ended", "Ended"


class StreamPlatformChoices(models.TextChoices):
    TWITCH = "Twitch", "Twitch"
    YOUTUBE = "YouTube", "Youtube"
    KICKSTREAM = "KickStream", "Kickstream"
    PLATFORM = "Platform", "Platform"


class StreamLanguageChoices(models.TextChoices):
    EN = "EN", "En"
    DE = "DE", "De"
    FR = "FR", "Fr"
    IT = "IT", "It"
    ES = "ES", "Es"
    JP = "JP", "Jp"
    PT = "PT", "Pt"


class Stream(models.Model):
    title = models.CharField(max_length=300)
    stream_url = models.URLField(max_length=200)
    status = models.CharField(max_length=20, choices=StreamStatusChoices.choices, default=StreamStatusChoices.SCHEDULED)
    platform = models.CharField(max_length=20, choices=StreamPlatformChoices.choices, default=StreamPlatformChoices.TWITCH)
    language = models.CharField(max_length=20, choices=StreamLanguageChoices.choices, default=StreamLanguageChoices.EN)
    is_official = models.BooleanField(default=False)
    viewer_count_peak = models.IntegerField(default=0)
    scheduled_start = models.DateTimeField()
    actual_start = models.DateTimeField(null=True, blank=True)
    ended_at = models.DateTimeField(null=True, blank=True)
    vod_url = models.URLField(max_length=200, null=True, blank=True)
    tournament = models.ForeignKey("tournaments.Tournament", on_delete=models.CASCADE, related_name="streams", null=True, blank=True)
    streamer = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="streams")

    class Meta:
        verbose_name = "Stream"
        verbose_name_plural = "Streams"
        ordering = ["-id"]

    def __str__(self):
        return str(self.title)

    # ── Business operations ──────────────────────────────────────────

    def go_live(self):
        # TODO: implement go_live
        pass

    def end(self):
        # TODO: implement end
        pass

    def update_viewer_peak(self, count):
        # TODO: implement update_viewer_peak
        pass

    def duration_minutes(self):
        # TODO: implement duration_minutes
        return None

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.viewer_count_peak is None or self.viewer_count_peak >= 0)):
            errors["viewer_count_not_negative"] = "Peak viewer count must not be negative"
        if errors:
            raise ValidationError(errors)

    def validate_implies(self):
        from django.core.exceptions import ValidationError
        if (self.actual_start is not None) and (not (self.status == StreamStatusChoices.LIVE)):
            raise ValidationError({"actual_start_requires_live_or_ended": "actual_start_requires_live_or_ended"})
        if (self.ended_at is not None) and (not (self.status == StreamStatusChoices.ENDED)):
            raise ValidationError({"ended_at_requires_ended_status": "ended_at can only be set when stream status is Ended"})

    # ── Lifecycle state machine ──────────────────────────────────────
    ALLOWED_TRANSITIONS = {
        "Scheduled": ["Live"],
        "Live": ["Ended"],
    }

    def assert_transition(self, to_state):
        from django.core.exceptions import ValidationError
        allowed = self.ALLOWED_TRANSITIONS.get(self.status, [])
        if to_state not in allowed:
            raise ValidationError(f"Transition {self.status} -> {to_state} not allowed")
