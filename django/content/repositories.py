"""
Repository layer for the Content BC bounded context.
Abstracts data access from domain logic.
"""


class DraftSessionRepository:
    """Repository for DraftSession."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import DraftSession
        return DraftSession.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import DraftSession
        return DraftSession.objects.all()


class DraftParticipantRepository:
    """Repository for DraftParticipant."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import DraftParticipant
        return DraftParticipant.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import DraftParticipant
        return DraftParticipant.objects.all()


class DraftPickRepository:
    """Repository for DraftPick."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import DraftPick
        return DraftPick.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import DraftPick
        return DraftPick.objects.all()


class ArticleRepository:
    """Repository for Article."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import Article
        return Article.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import Article
        return Article.objects.all()


class ArticleTagRepository:
    """Repository for ArticleTag."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import ArticleTag
        return ArticleTag.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import ArticleTag
        return ArticleTag.objects.all()


class ArticleTagAssignmentRepository:
    """Repository for ArticleTagAssignment."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import ArticleTagAssignment
        return ArticleTagAssignment.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import ArticleTagAssignment
        return ArticleTagAssignment.objects.all()


class ArticleCommentRepository:
    """Repository for ArticleComment."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import ArticleComment
        return ArticleComment.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import ArticleComment
        return ArticleComment.objects.all()


class StreamRepository:
    """Repository for Stream."""

    @staticmethod
    def get_by_id(pk: int):
        from .models import Stream
        return Stream.objects.filter(pk=pk).first()

    @staticmethod
    def find_all():
        from .models import Stream
        return Stream.objects.all()
