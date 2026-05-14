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
        raise NotImplementedError("start not implemented")

    def abandon(self):
        raise NotImplementedError("abandon not implemented")

    def complete(self):
        raise NotImplementedError("complete not implemented")

    def is_full(self):
        raise NotImplementedError("is_full not implemented")


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
        raise NotImplementedError("pick_card not implemented")

    def drafted_card_count(self):
        raise NotImplementedError("drafted_card_count not implemented")


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
        raise NotImplementedError("is_first_pick not implemented")


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


class Article(models.Model):
    title = models.CharField(max_length=300)
    slug = models.CharField(max_length=300)
    body = models.TextField()
    excerpt = models.TextField(null=True, blank=True)
    cover_image_url = models.URLField(max_length=200, null=True, blank=True)
    status = models.CharField(max_length=20, choices=ArticleStatusChoices.choices, default=ArticleStatusChoices.DRAFT)
    article_type = models.CharField(max_length=20, choices=ArticleArticleTypeChoices.choices, default=ArticleArticleTypeChoices.GUIDE)
    view_count = models.IntegerField(default=0)
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
        raise NotImplementedError("publish not implemented")

    def archive(self):
        raise NotImplementedError("archive not implemented")

    def increment_view(self):
        raise NotImplementedError("increment_view not implemented")

    def reading_time_minutes(self):
        raise NotImplementedError("reading_time_minutes not implemented")

    def validate_implies(self):
        from django.core.exceptions import ValidationError
        if (self.status == ArticleStatusChoices.PUBLISHED) and (self.published_at is None):
            raise ValidationError({"published_requires_published_at": "Published article must have a published_at timestamp"})


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
        raise NotImplementedError("rename not implemented")

    def article_count(self):
        raise NotImplementedError("article_count not implemented")


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
        raise NotImplementedError("hide not implemented")

    def unhide(self):
        raise NotImplementedError("unhide not implemented")

    def is_reply(self):
        raise NotImplementedError("is_reply not implemented")


class StreamPlatformChoices(models.TextChoices):
    TWITCH = "Twitch", "Twitch"
    YOUTUBE = "YouTube", "Youtube"
    KICKSTREAM = "KickStream", "Kickstream"
    PLATFORM = "Platform", "Platform"


class StreamStatusChoices(models.TextChoices):
    SCHEDULED = "Scheduled", "Scheduled"
    LIVE = "Live", "Live"
    ENDED = "Ended", "Ended"


class Stream(models.Model):
    title = models.CharField(max_length=300)
    stream_url = models.URLField(max_length=200)
    platform = models.CharField(max_length=20, choices=StreamPlatformChoices.choices, default=StreamPlatformChoices.TWITCH)
    status = models.CharField(max_length=20, choices=StreamStatusChoices.choices, default=StreamStatusChoices.SCHEDULED)
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
        raise NotImplementedError("go_live not implemented")

    def end(self):
        raise NotImplementedError("end not implemented")

    def update_viewer_peak(self, count):
        raise NotImplementedError("update_viewer_peak not implemented")

    def duration_minutes(self):
        raise NotImplementedError("duration_minutes not implemented")

    def validate_implies(self):
        from django.core.exceptions import ValidationError
        if (self.actual_start is not None) and (not (self.status == StreamStatusChoices.LIVE)):
            raise ValidationError({"actual_start_requires_live_or_ended": "actual_start_requires_live_or_ended"})
