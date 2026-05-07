from django.conf import settings
from django.db import models


class StatusChoices(models.TextChoices):
    WAITINGFORPLAYERS = "WaitingForPlayers", "Waitingforplayers"
    DRAFTING = "Drafting", "Drafting"
    COMPLETED = "Completed", "Completed"
    ABANDONED = "Abandoned", "Abandoned"


class DraftTypeChoices(models.TextChoices):
    BOOSTER = "Booster", "Booster"
    CUBE = "Cube", "Cube"
    ROCHESTER = "Rochester", "Rochester"


class DraftSession(models.Model):
    status = models.CharField(max_length=20, choices=StatusChoices.choices, default=StatusChoices.WAITINGFORPLAYERS)
    draft_type = models.CharField(max_length=20, choices=DraftTypeChoices.choices, default=DraftTypeChoices.BOOSTER)
    seats = models.IntegerField(default=8)
    created_at = models.DateTimeField()
    completed_at = models.DateTimeField(null=True, blank=True)
    card_set = models.ForeignKey("cards.CardSet", on_delete=models.CASCADE, related_name="draft_sessions")
    participants = models.ForeignKey("DraftParticipant", on_delete=models.CASCADE)

    class Meta:
        verbose_name = "Draft Session"
        verbose_name_plural = "Draft Sessions"
        ordering = ["-id"]

    def __str__(self):
        return str(self.status)


class DraftParticipant(models.Model):
    seat_number = models.IntegerField()
    joined_at = models.DateTimeField()
    session = models.ForeignKey("DraftSession", on_delete=models.CASCADE, null=True, blank=True)
    player = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="draft_sessions")
    drafted_cards = models.ForeignKey("DraftPick", on_delete=models.CASCADE, null=True, blank=True)

    class Meta:
        verbose_name = "Draft Participant"
        verbose_name_plural = "Draft Participants"
        ordering = ["-id"]

    def __str__(self):
        return str(self.seat_number)


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


class StatusChoices(models.TextChoices):
    DRAFT = "Draft", "Draft"
    PUBLISHED = "Published", "Published"
    ARCHIVED = "Archived", "Archived"


class ArticleTypeChoices(models.TextChoices):
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
    status = models.CharField(max_length=20, choices=StatusChoices.choices, default=StatusChoices.DRAFT)
    article_type = models.CharField(max_length=20, choices=ArticleTypeChoices.choices, default=ArticleTypeChoices.GUIDE)
    view_count = models.IntegerField(default=0)
    published_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    author = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="articles")
    featured_deck = models.ForeignKey("cards.Deck", on_delete=models.CASCADE, related_name="articles", null=True, blank=True)
    tags = models.ManyToManyField("ArticleTag", through="ArticleTagAssignment")
    comments = models.ForeignKey("ArticleComment", on_delete=models.CASCADE)

    class Meta:
        verbose_name = "Article"
        verbose_name_plural = "Articles"
        ordering = ["-id"]

    def __str__(self):
        return str(self.title)


class ArticleTag(models.Model):
    name = models.CharField(max_length=100)
    slug = models.CharField(max_length=100)

    class Meta:
        verbose_name = "Article Tag"
        verbose_name_plural = "Article Tags"
        ordering = ["-id"]

    def __str__(self):
        return str(self.name)


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


class PlatformChoices(models.TextChoices):
    TWITCH = "Twitch", "Twitch"
    YOUTUBE = "YouTube", "Youtube"
    KICKSTREAM = "KickStream", "Kickstream"
    PLATFORM = "Platform", "Platform"


class StatusChoices(models.TextChoices):
    SCHEDULED = "Scheduled", "Scheduled"
    LIVE = "Live", "Live"
    ENDED = "Ended", "Ended"


class Stream(models.Model):
    title = models.CharField(max_length=300)
    stream_url = models.URLField(max_length=200)
    platform = models.CharField(max_length=20, choices=PlatformChoices.choices, default=PlatformChoices.TWITCH)
    status = models.CharField(max_length=20, choices=StatusChoices.choices, default=StatusChoices.SCHEDULED)
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
