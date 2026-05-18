"""
Domain services for the Content BC bounded context.
Place business logic that does not belong to a single model here.
"""

from sqlalchemy.orm import Session

from .models import DraftSession, DraftParticipant, DraftPick, Article, ArticleTag, ArticleTagAssignment, ArticleComment, Stream


class DraftSessionService:
    """Domain service for DraftSession aggregate."""

    @staticmethod
    def start(db: Session, pk: int):
        obj = db.query(DraftSession).filter(DraftSession.id == pk).first()
        if obj is None:
            raise ValueError("DraftSession not found: " + str(pk))
        obj.start()
        db.add(obj)
        db.commit()

    @staticmethod
    def abandon(db: Session, pk: int):
        obj = db.query(DraftSession).filter(DraftSession.id == pk).first()
        if obj is None:
            raise ValueError("DraftSession not found: " + str(pk))
        obj.abandon()
        db.add(obj)
        db.commit()

    @staticmethod
    def complete(db: Session, pk: int):
        obj = db.query(DraftSession).filter(DraftSession.id == pk).first()
        if obj is None:
            raise ValueError("DraftSession not found: " + str(pk))
        obj.complete()
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class DraftParticipantService:
    """Domain service for DraftParticipant aggregate."""

    @staticmethod
    def pick_card(db: Session, pk: int, card_id: int, pack_number: int):
        obj = db.query(DraftParticipant).filter(DraftParticipant.id == pk).first()
        if obj is None:
            raise ValueError("DraftParticipant not found: " + str(pk))
        obj.pick_card(card_id, pack_number)
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class DraftPickService:
    """Domain service for DraftPick aggregate."""

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class ArticleService:
    """Domain service for Article aggregate."""

    @staticmethod
    def publish(db: Session, pk: int):
        obj = db.query(Article).filter(Article.id == pk).first()
        if obj is None:
            raise ValueError("Article not found: " + str(pk))
        obj.publish()
        db.add(obj)
        db.commit()

    @staticmethod
    def archive(db: Session, pk: int):
        obj = db.query(Article).filter(Article.id == pk).first()
        if obj is None:
            raise ValueError("Article not found: " + str(pk))
        obj.archive()
        db.add(obj)
        db.commit()

    @staticmethod
    def increment_view(db: Session, pk: int):
        obj = db.query(Article).filter(Article.id == pk).first()
        if obj is None:
            raise ValueError("Article not found: " + str(pk))
        obj.increment_view()
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class ArticleTagService:
    """Domain service for ArticleTag aggregate."""

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class ArticleTagAssignmentService:
    """Domain service for ArticleTagAssignment aggregate."""

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class ArticleCommentService:
    """Domain service for ArticleComment aggregate."""

    @staticmethod
    def hide(db: Session, pk: int):
        obj = db.query(ArticleComment).filter(ArticleComment.id == pk).first()
        if obj is None:
            raise ValueError("ArticleComment not found: " + str(pk))
        obj.hide()
        db.add(obj)
        db.commit()

    @staticmethod
    def unhide(db: Session, pk: int):
        obj = db.query(ArticleComment).filter(ArticleComment.id == pk).first()
        if obj is None:
            raise ValueError("ArticleComment not found: " + str(pk))
        obj.unhide()
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class StreamService:
    """Domain service for Stream aggregate."""

    @staticmethod
    def go_live(db: Session, pk: int):
        obj = db.query(Stream).filter(Stream.id == pk).first()
        if obj is None:
            raise ValueError("Stream not found: " + str(pk))
        obj.go_live()
        db.add(obj)
        db.commit()

    @staticmethod
    def end(db: Session, pk: int):
        obj = db.query(Stream).filter(Stream.id == pk).first()
        if obj is None:
            raise ValueError("Stream not found: " + str(pk))
        obj.end()
        db.add(obj)
        db.commit()

    @staticmethod
    def update_viewer_peak(db: Session, pk: int, count: int):
        obj = db.query(Stream).filter(Stream.id == pk).first()
        if obj is None:
            raise ValueError("Stream not found: " + str(pk))
        obj.update_viewer_peak(count)
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError
