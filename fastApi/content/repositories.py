"""
Repository layer for the Content BC bounded context.
Abstracts data access from domain logic.
"""

from sqlalchemy.orm import Session

from .models import DraftSession, DraftParticipant, DraftPick, Article, ArticleTag, ArticleTagAssignment, ArticleComment, Stream


class DraftSessionRepository:
    """Repository for DraftSession."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> DraftSession | None:
        return db.query(DraftSession).filter(DraftSession.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[DraftSession]:
        return db.query(DraftSession).all()


class DraftParticipantRepository:
    """Repository for DraftParticipant."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> DraftParticipant | None:
        return db.query(DraftParticipant).filter(DraftParticipant.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[DraftParticipant]:
        return db.query(DraftParticipant).all()


class DraftPickRepository:
    """Repository for DraftPick."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> DraftPick | None:
        return db.query(DraftPick).filter(DraftPick.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[DraftPick]:
        return db.query(DraftPick).all()


class ArticleRepository:
    """Repository for Article."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> Article | None:
        return db.query(Article).filter(Article.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[Article]:
        return db.query(Article).all()


class ArticleTagRepository:
    """Repository for ArticleTag."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> ArticleTag | None:
        return db.query(ArticleTag).filter(ArticleTag.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[ArticleTag]:
        return db.query(ArticleTag).all()


class ArticleTagAssignmentRepository:
    """Repository for ArticleTagAssignment."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> ArticleTagAssignment | None:
        return db.query(ArticleTagAssignment).filter(ArticleTagAssignment.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[ArticleTagAssignment]:
        return db.query(ArticleTagAssignment).all()


class ArticleCommentRepository:
    """Repository for ArticleComment."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> ArticleComment | None:
        return db.query(ArticleComment).filter(ArticleComment.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[ArticleComment]:
        return db.query(ArticleComment).all()


class StreamRepository:
    """Repository for Stream."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> Stream | None:
        return db.query(Stream).filter(Stream.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[Stream]:
        return db.query(Stream).all()
