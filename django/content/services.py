"""
Domain services for the Content BC bounded context.
Place business logic that doesn't belong to a single model here.
"""


class DraftSessionService:
    """Domain service for DraftSession aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new DraftSession."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing DraftSession."""
        raise NotImplementedError

    @staticmethod
    def start(id):
        from .models import DraftSession
        instance = DraftSession.objects.get(pk=id)
        instance.start()
        instance.save()

    @staticmethod
    def abandon(id):
        from .models import DraftSession
        instance = DraftSession.objects.get(pk=id)
        instance.abandon()
        instance.save()

    @staticmethod
    def complete(id):
        from .models import DraftSession
        instance = DraftSession.objects.get(pk=id)
        instance.complete()
        instance.save()


class DraftParticipantService:
    """Domain service for DraftParticipant aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new DraftParticipant."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing DraftParticipant."""
        raise NotImplementedError

    @staticmethod
    def pick_card(id, card_id, pack_number):
        from .models import DraftParticipant
        instance = DraftParticipant.objects.get(pk=id)
        instance.pick_card(card_id, pack_number)
        instance.save()


class DraftPickService:
    """Domain service for DraftPick aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new DraftPick."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing DraftPick."""
        raise NotImplementedError


class ArticleService:
    """Domain service for Article aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new Article."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing Article."""
        raise NotImplementedError

    @staticmethod
    def publish(id):
        from .models import Article
        instance = Article.objects.get(pk=id)
        instance.publish()
        instance.save()

    @staticmethod
    def archive(id):
        from .models import Article
        instance = Article.objects.get(pk=id)
        instance.archive()
        instance.save()

    @staticmethod
    def increment_view(id):
        from .models import Article
        instance = Article.objects.get(pk=id)
        instance.increment_view()
        instance.save()


class ArticleTagService:
    """Domain service for ArticleTag aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new ArticleTag."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing ArticleTag."""
        raise NotImplementedError


class ArticleTagAssignmentService:
    """Domain service for ArticleTagAssignment aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new ArticleTagAssignment."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing ArticleTagAssignment."""
        raise NotImplementedError


class ArticleCommentService:
    """Domain service for ArticleComment aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new ArticleComment."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing ArticleComment."""
        raise NotImplementedError

    @staticmethod
    def hide(id):
        from .models import ArticleComment
        instance = ArticleComment.objects.get(pk=id)
        instance.hide()
        instance.save()

    @staticmethod
    def unhide(id):
        from .models import ArticleComment
        instance = ArticleComment.objects.get(pk=id)
        instance.unhide()
        instance.save()


class StreamService:
    """Domain service for Stream aggregate."""

    @staticmethod
    def create(data: dict):
        """Create a new Stream."""
        raise NotImplementedError

    @staticmethod
    def update(instance, data: dict):
        """Update an existing Stream."""
        raise NotImplementedError

    @staticmethod
    def go_live(id):
        from .models import Stream
        instance = Stream.objects.get(pk=id)
        instance.go_live()
        instance.save()

    @staticmethod
    def end(id):
        from .models import Stream
        instance = Stream.objects.get(pk=id)
        instance.end()
        instance.save()

    @staticmethod
    def update_viewer_peak(id, count):
        from .models import Stream
        instance = Stream.objects.get(pk=id)
        instance.update_viewer_peak(count)
        instance.save()
