from __future__ import annotations

from sqlalchemy import (
    Boolean, Column, Date, DateTime, Float, ForeignKey, Integer,
    JSON, Numeric, SmallInteger, String, Table, Text,
)
from sqlalchemy.orm import relationship

from app.db import Base

from typing import Literal

DraftSessionStatusType = Literal["WaitingForPlayers", "Drafting", "Completed", "Abandoned"]
DraftSessionDraftTypeType = Literal["Booster", "Cube", "Rochester"]

class DraftSession(Base):
    __tablename__ = "draft_session"

    id = Column(Integer, primary_key=True, index=True)
    status = Column(String(20), default="WaitingForPlayers")
    draft_type = Column(String(20), default="Booster")
    seats = Column(Integer, default="8")
    time_per_pick_seconds = Column(Integer, default="30")
    created_at = Column(DateTime)
    completed_at = Column(DateTime, nullable=True)
    card_set_id = Column(Integer, ForeignKey("card_set.id", ondelete="CASCADE"), nullable=False)
    card_set = relationship("CardSet", foreign_keys=[card_set_id], backref="draft_sessions")

    def start(self):
        # TODO: implement start
        pass

    def abandon(self):
        # TODO: implement abandon
        pass

    def complete(self):
        # TODO: implement complete
        pass

    def is_full(self) -> bool:
        # TODO: implement is_full
        return None  # type: ignore


    # ── Lifecycle state machine ──────────────────────────────────────
    ALLOWED_TRANSITIONS: dict = {
        "WaitingForPlayers": ["Drafting", "Abandoned"],
        "Drafting": ["Completed", "Abandoned"]
    }

    def assert_transition(self, to: str) -> None:
        allowed = self.ALLOWED_TRANSITIONS.get(self.status, [])
        if to not in allowed:
            raise ValueError(f"Transition {self.status} -> {to} not allowed")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.seats is None or (self.seats >= 2 and self.seats <= 16))):
            errors.append("Draft session must have between 2 and 16 seats")
        if not ((self.time_per_pick_seconds is None or self.time_per_pick_seconds > 0)):
            errors.append("Time per pick must be greater than zero")
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
    session_id = Column(Integer, ForeignKey("draft_session.id", ondelete="CASCADE"), nullable=True)
    session = relationship("DraftSession", foreign_keys=[session_id], backref="participants")
    player_id = Column(Integer, ForeignKey("player.id", ondelete="CASCADE"), nullable=False)
    player = relationship("Player", foreign_keys=[player_id], backref="draft_sessions")

    def pick_card(self, card_id: int, pack_number: int):
        # TODO: implement pick_card
        pass

    def drafted_card_count(self) -> int:
        # TODO: implement drafted_card_count
        return None  # type: ignore


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
    participant_id = Column(Integer, ForeignKey("draft_participant.id", ondelete="CASCADE"), nullable=False)
    participant = relationship("DraftParticipant", foreign_keys=[participant_id], backref="picks")
    card_id = Column(Integer, ForeignKey("card.id", ondelete="CASCADE"), nullable=False)
    card = relationship("Card", foreign_keys=[card_id], backref="draft_picks")

    def is_first_pick(self) -> bool:
        # TODO: implement is_first_pick
        return None  # type: ignore


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
ArticleLanguageType = Literal["EN", "DE", "FR", "IT", "ES", "JP", "PT"]

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
    language = Column(String(20), default="EN")
    view_count = Column(Integer, default="0")
    likes_count = Column(Integer, default="0")
    is_featured = Column(Boolean, default="false")
    published_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime)
    updated_at = Column(DateTime)
    author_id = Column(Integer, ForeignKey("player.id", ondelete="CASCADE"), nullable=False)
    author = relationship("Player", foreign_keys=[author_id], backref="articles")
    featured_deck_id = Column(Integer, ForeignKey("deck.id", ondelete="CASCADE"), nullable=True)
    featured_deck = relationship("Deck", foreign_keys=[featured_deck_id], backref="articles")

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

    def reading_time_minutes(self) -> int:
        # TODO: implement reading_time_minutes
        return None  # type: ignore


    # ── Lifecycle state machine ──────────────────────────────────────
    ALLOWED_TRANSITIONS: dict = {
        "Draft": ["Published"],
        "Published": ["Archived"],
        "Archived": ["Draft"]
    }

    def assert_transition(self, to: str) -> None:
        allowed = self.ALLOWED_TRANSITIONS.get(self.status, [])
        if to not in allowed:
            raise ValueError(f"Transition {self.status} -> {to} not allowed")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.view_count is None or self.view_count >= 0)):
            errors.append("Article view count must not be negative")
        if not ((self.likes_count is None or self.likes_count >= 0)):
            errors.append("Article likes count must not be negative")
        return errors

    def validate_implies(self) -> list[str]:
        errors = []
        if (self.status == "Published") and not (self.published_at is not None):
            errors.append("Published article must have a published_at timestamp")
        return errors
    # ── Lifecycle hooks ──────────────────────────────────────────────
    def _hook_update_search_index(self) -> None:
        # TODO: implement update_search_index
        pass

    def __repr__(self) -> str:
        return f"<Article id={{self.id}}>"


class ArticleTag(Base):
    __tablename__ = "article_tag"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100))
    slug = Column(String(100))

    def rename(self, new_name: str):
        # TODO: implement rename
        pass

    def article_count(self) -> int:
        # TODO: implement article_count
        return None  # type: ignore

    def __repr__(self) -> str:
        return f"<ArticleTag id={{self.id}}>"


class ArticleTagAssignment(Base):
    __tablename__ = "article_tag_assignment"

    id = Column(Integer, primary_key=True, index=True)
    article_id = Column(Integer, ForeignKey("article.id", ondelete="CASCADE"), nullable=False)
    article = relationship("Article", foreign_keys=[article_id], backref="tag_assignments")
    tag_id = Column(Integer, ForeignKey("article_tag.id", ondelete="CASCADE"), nullable=False)
    tag = relationship("ArticleTag", foreign_keys=[tag_id], backref="article_assignments")
    def __repr__(self) -> str:
        return f"<ArticleTagAssignment id={{self.id}}>"


class ArticleComment(Base):
    __tablename__ = "article_comment"

    id = Column(Integer, primary_key=True, index=True)
    body = Column(Text)
    is_hidden = Column(Boolean, default="false")
    created_at = Column(DateTime)
    article_id = Column(Integer, ForeignKey("article.id", ondelete="CASCADE"), nullable=True)
    article = relationship("Article", foreign_keys=[article_id], backref="comments")
    author_id = Column(Integer, ForeignKey("player.id", ondelete="CASCADE"), nullable=False)
    author = relationship("Player", foreign_keys=[author_id], backref="article_comments")
    parent_comment_id = Column(Integer, ForeignKey("article_comment.id", ondelete="CASCADE"), nullable=True)
    parent_comment = relationship("ArticleComment", foreign_keys=[parent_comment_id], remote_side=[id], backref="replies")

    def hide(self):
        # TODO: implement hide
        pass

    def unhide(self):
        # TODO: implement unhide
        pass

    def is_reply(self) -> bool:
        # TODO: implement is_reply
        return None  # type: ignore

    def __repr__(self) -> str:
        return f"<ArticleComment id={{self.id}}>"


from typing import Literal

StreamStatusType = Literal["Scheduled", "Live", "Ended"]
StreamPlatformType = Literal["Twitch", "YouTube", "KickStream", "Platform"]
StreamLanguageType = Literal["EN", "DE", "FR", "IT", "ES", "JP", "PT"]

class Stream(Base):
    __tablename__ = "stream"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(300))
    stream_url = Column(String(200))
    status = Column(String(20), default="Scheduled")
    platform = Column(String(20), default="Twitch")
    language = Column(String(20), default="EN")
    is_official = Column(Boolean, default="false")
    viewer_count_peak = Column(Integer, default="0")
    scheduled_start = Column(DateTime)
    actual_start = Column(DateTime, nullable=True)
    ended_at = Column(DateTime, nullable=True)
    vod_url = Column(String(200), nullable=True)
    tournament_id = Column(Integer, ForeignKey("tournament.id", ondelete="CASCADE"), nullable=True)
    tournament = relationship("Tournament", foreign_keys=[tournament_id], backref="streams")
    streamer_id = Column(Integer, ForeignKey("player.id", ondelete="CASCADE"), nullable=False)
    streamer = relationship("Player", foreign_keys=[streamer_id], backref="streams")

    def go_live(self):
        # TODO: implement go_live
        pass

    def end(self):
        # TODO: implement end
        pass

    def update_viewer_peak(self, count: int):
        # TODO: implement update_viewer_peak
        pass

    def duration_minutes(self) -> int:
        # TODO: implement duration_minutes
        return None  # type: ignore


    # ── Lifecycle state machine ──────────────────────────────────────
    ALLOWED_TRANSITIONS: dict = {
        "Scheduled": ["Live"],
        "Live": ["Ended"]
    }

    def assert_transition(self, to: str) -> None:
        allowed = self.ALLOWED_TRANSITIONS.get(self.status, [])
        if to not in allowed:
            raise ValueError(f"Transition {self.status} -> {to} not allowed")


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



# ── SQLAlchemy event listeners ───────────────────────────────────────────
from sqlalchemy import event

@event.listens_for(Article, "after_insert")
@event.listens_for(Article, "after_update")
def _article_update_search_index(mapper, connection, target):
    target._hook_update_search_index()
