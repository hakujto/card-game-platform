from __future__ import annotations

from sqlalchemy import (
    Boolean, Column, Date, DateTime, Float, ForeignKey, Integer,
    JSON, Numeric, SmallInteger, String, Table, Text,
)
from sqlalchemy.orm import relationship

from app.db import Base

article_tags_assoc = Table(
    "article_tags_m2m",
    Base.metadata,
    Column("article_id", Integer, ForeignKey("article.id"), primary_key=True),
    Column("article_tag_id", Integer, ForeignKey("article_tag.id"), primary_key=True),
)

from typing import Literal

DraftSessionStatusType = Literal["WaitingForPlayers", "Drafting", "Completed", "Abandoned"]
DraftSessionDraftTypeType = Literal["Booster", "Cube", "Rochester"]

class DraftSession(Base):
    __tablename__ = "draft_session"

    id = Column(Integer, primary_key=True, index=True)
    status = Column(String(20), default="WaitingForPlayers")
    draft_type = Column(String(20), default="Booster")
    seats = Column(Integer, default="8")
    created_at = Column(DateTime)
    completed_at = Column(DateTime, nullable=True)
    card_set_id = Column(Integer, ForeignKey("card_set.id"), nullable=False)
    card_set = relationship("CardSet", foreign_keys=[card_set_id])

    def start(self):
        raise NotImplementedError("start not implemented")

    def abandon(self):
        raise NotImplementedError("abandon not implemented")

    def complete(self):
        raise NotImplementedError("complete not implemented")

    def is_full(self) -> bool:
        raise NotImplementedError("is_full not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.seats is None or (self.seats >= 2 and self.seats <= 16))):
            errors.append("Draft session must have between 2 and 16 seats")
        return errors

    def validate_implies(self) -> list[str]:
        errors = []
        if (self.completed_at is not None) and not (self.status == "Completed"):
            errors.append("completed_at can only be set when draft status is Completed")
        return errors
    def __repr__(self) -> str:
        return f"<DraftSession id={{self.id}}>"


class DraftParticipant(Base):
    __tablename__ = "draft_participant"

    id = Column(Integer, primary_key=True, index=True)
    seat_number = Column(Integer)
    joined_at = Column(DateTime)
    session_id = Column(Integer, ForeignKey("draft_session.id"), nullable=True)
    session = relationship("DraftSession", foreign_keys=[session_id])
    player_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    player = relationship("Player", foreign_keys=[player_id])

    def pick_card(self, card_id: int, pack_number: int):
        raise NotImplementedError("pick_card not implemented")

    def drafted_card_count(self) -> int:
        raise NotImplementedError("drafted_card_count not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.seat_number is None or self.seat_number > 0)):
            errors.append("Seat number must be greater than zero")
        return errors
    def __repr__(self) -> str:
        return f"<DraftParticipant id={{self.id}}>"


class DraftPick(Base):
    __tablename__ = "draft_pick"

    id = Column(Integer, primary_key=True, index=True)
    pick_number = Column(Integer)
    pack_number = Column(Integer)
    picked_at = Column(DateTime)
    participant_id = Column(Integer, ForeignKey("draft_participant.id"), nullable=False)
    participant = relationship("DraftParticipant", foreign_keys=[participant_id])
    card_id = Column(Integer, ForeignKey("card.id"), nullable=False)
    card = relationship("Card", foreign_keys=[card_id])

    def is_first_pick(self) -> bool:
        raise NotImplementedError("is_first_pick not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.pick_number is None or self.pick_number > 0)):
            errors.append("Pick number must be greater than zero")
        if not ((self.pack_number is None or (self.pack_number >= 1 and self.pack_number <= 3))):
            errors.append("Pack number must be between 1 and 3")
        return errors
    def __repr__(self) -> str:
        return f"<DraftPick id={{self.id}}>"


from typing import Literal

ArticleStatusType = Literal["Draft", "Published", "Archived"]
ArticleArticleTypeType = Literal["Guide", "Tierlist", "Matchup", "News", "Spotlight", "Decklist"]

class Article(Base):
    __tablename__ = "article"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(300))
    slug = Column(String(300))
    body = Column(Text)
    excerpt = Column(Text, nullable=True)
    cover_image_url = Column(String(200), nullable=True)
    status = Column(String(20), default="Draft")
    article_type = Column(String(20), default="Guide")
    view_count = Column(Integer, default="0")
    published_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime)
    updated_at = Column(DateTime)
    author_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    author = relationship("Player", foreign_keys=[author_id])
    featured_deck_id = Column(Integer, ForeignKey("deck.id"), nullable=True)
    featured_deck = relationship("Deck", foreign_keys=[featured_deck_id])
    tags = relationship("ArticleTag", secondary=article_tags_assoc)

    def publish(self):
        raise NotImplementedError("publish not implemented")

    def archive(self):
        raise NotImplementedError("archive not implemented")

    def increment_view(self):
        raise NotImplementedError("increment_view not implemented")

    def reading_time_minutes(self) -> int:
        raise NotImplementedError("reading_time_minutes not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.view_count is None or self.view_count >= 0)):
            errors.append("Article view count must not be negative")
        return errors

    def validate_implies(self) -> list[str]:
        errors = []
        if (self.status == "Published") and not (self.published_at is not None):
            errors.append("Published article must have a published_at timestamp")
        return errors
    def __repr__(self) -> str:
        return f"<Article id={{self.id}}>"


class ArticleTag(Base):
    __tablename__ = "article_tag"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100))
    slug = Column(String(100))

    def rename(self, new_name: str):
        raise NotImplementedError("rename not implemented")

    def article_count(self) -> int:
        raise NotImplementedError("article_count not implemented")

    def __repr__(self) -> str:
        return f"<ArticleTag id={{self.id}}>"


class ArticleTagAssignment(Base):
    __tablename__ = "article_tag_assignment"

    id = Column(Integer, primary_key=True, index=True)
    article_id = Column(Integer, ForeignKey("article.id"), nullable=False)
    article = relationship("Article", foreign_keys=[article_id])
    tag_id = Column(Integer, ForeignKey("article_tag.id"), nullable=False)
    tag = relationship("ArticleTag", foreign_keys=[tag_id])
    def __repr__(self) -> str:
        return f"<ArticleTagAssignment id={{self.id}}>"


class ArticleComment(Base):
    __tablename__ = "article_comment"

    id = Column(Integer, primary_key=True, index=True)
    body = Column(Text)
    is_hidden = Column(Boolean, default="false")
    created_at = Column(DateTime)
    article_id = Column(Integer, ForeignKey("article.id"), nullable=True)
    article = relationship("Article", foreign_keys=[article_id])
    author_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    author = relationship("Player", foreign_keys=[author_id])
    parent_comment_id = Column(Integer, ForeignKey("article_comment.id"), nullable=True)
    parent_comment = relationship("ArticleComment", foreign_keys=[parent_comment_id])

    def hide(self):
        raise NotImplementedError("hide not implemented")

    def unhide(self):
        raise NotImplementedError("unhide not implemented")

    def is_reply(self) -> bool:
        raise NotImplementedError("is_reply not implemented")

    def __repr__(self) -> str:
        return f"<ArticleComment id={{self.id}}>"


from typing import Literal

StreamPlatformType = Literal["Twitch", "YouTube", "KickStream", "Platform"]
StreamStatusType = Literal["Scheduled", "Live", "Ended"]

class Stream(Base):
    __tablename__ = "stream"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(300))
    stream_url = Column(String(200))
    platform = Column(String(20), default="Twitch")
    status = Column(String(20), default="Scheduled")
    viewer_count_peak = Column(Integer, default="0")
    scheduled_start = Column(DateTime)
    actual_start = Column(DateTime, nullable=True)
    ended_at = Column(DateTime, nullable=True)
    vod_url = Column(String(200), nullable=True)
    tournament_id = Column(Integer, ForeignKey("tournament.id"), nullable=True)
    tournament = relationship("Tournament", foreign_keys=[tournament_id])
    streamer_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    streamer = relationship("Player", foreign_keys=[streamer_id])

    def go_live(self):
        raise NotImplementedError("go_live not implemented")

    def end(self):
        raise NotImplementedError("end not implemented")

    def update_viewer_peak(self, count: int):
        raise NotImplementedError("update_viewer_peak not implemented")

    def duration_minutes(self) -> int:
        raise NotImplementedError("duration_minutes not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.viewer_count_peak is None or self.viewer_count_peak >= 0)):
            errors.append("Peak viewer count must not be negative")
        return errors

    def validate_implies(self) -> list[str]:
        errors = []
        if (self.actual_start is not None) and not (self.status == "Live"):
            errors.append("actual_start_requires_live_or_ended")
        if (self.ended_at is not None) and not (self.status == "Ended"):
            errors.append("ended_at can only be set when stream status is Ended")
        return errors
    def __repr__(self) -> str:
        return f"<Stream id={{self.id}}>"
