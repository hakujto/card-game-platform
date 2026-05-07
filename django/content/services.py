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
