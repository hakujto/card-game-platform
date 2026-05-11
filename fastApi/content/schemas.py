from __future__ import annotations

from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict

class DraftSessionBase(BaseModel):
    status: str
    draft_type: str
    seats: int
    created_at: datetime
    completed_at: datetime | None = None
    card_set_id: int


class DraftSessionCreate(DraftSessionBase):
    pass


class DraftSessionUpdate(BaseModel):
    status: str | None = None
    draft_type: str | None = None
    seats: int | None = None
    created_at: datetime | None = None
    completed_at: datetime | None = None
    card_set_id: int | None = None


class DraftSessionRead(DraftSessionBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class DraftParticipantBase(BaseModel):
    seat_number: int
    joined_at: datetime
    session_id: int | None = None
    player_id: int


class DraftParticipantCreate(DraftParticipantBase):
    pass


class DraftParticipantUpdate(BaseModel):
    seat_number: int | None = None
    joined_at: datetime | None = None
    session_id: int | None = None
    player_id: int | None = None


class DraftParticipantRead(DraftParticipantBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class DraftPickBase(BaseModel):
    pick_number: int
    pack_number: int
    picked_at: datetime
    participant_id: int
    card_id: int


class DraftPickCreate(DraftPickBase):
    pass


class DraftPickUpdate(BaseModel):
    pick_number: int | None = None
    pack_number: int | None = None
    picked_at: datetime | None = None
    participant_id: int | None = None
    card_id: int | None = None


class DraftPickRead(DraftPickBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class ArticleBase(BaseModel):
    title: str
    slug: str
    body: str
    excerpt: str | None = None
    cover_image_url: str | None = None
    status: str
    article_type: str
    view_count: int
    published_at: datetime | None = None
    created_at: datetime
    updated_at: datetime
    author_id: int
    featured_deck_id: int | None = None
    tags_ids: list[int] = []


class ArticleCreate(ArticleBase):
    pass


class ArticleUpdate(BaseModel):
    title: str | None = None
    slug: str | None = None
    body: str | None = None
    excerpt: str | None = None
    cover_image_url: str | None = None
    status: str | None = None
    article_type: str | None = None
    view_count: int | None = None
    published_at: datetime | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None
    author_id: int | None = None
    featured_deck_id: int | None = None
    tags_ids: list[int] | None = None


class ArticleRead(ArticleBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class ArticleTagBase(BaseModel):
    name: str
    slug: str


class ArticleTagCreate(ArticleTagBase):
    pass


class ArticleTagUpdate(BaseModel):
    name: str | None = None
    slug: str | None = None


class ArticleTagRead(ArticleTagBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class ArticleTagAssignmentBase(BaseModel):
    article_id: int
    tag_id: int


class ArticleTagAssignmentCreate(ArticleTagAssignmentBase):
    pass


class ArticleTagAssignmentUpdate(BaseModel):
    article_id: int | None = None
    tag_id: int | None = None


class ArticleTagAssignmentRead(ArticleTagAssignmentBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class ArticleCommentBase(BaseModel):
    body: str
    is_hidden: bool
    created_at: datetime
    article_id: int | None = None
    author_id: int
    parent_comment_id: int | None = None


class ArticleCommentCreate(ArticleCommentBase):
    pass


class ArticleCommentUpdate(BaseModel):
    body: str | None = None
    is_hidden: bool | None = None
    created_at: datetime | None = None
    article_id: int | None = None
    author_id: int | None = None
    parent_comment_id: int | None = None


class ArticleCommentRead(ArticleCommentBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class StreamBase(BaseModel):
    title: str
    stream_url: str
    platform: str
    status: str
    viewer_count_peak: int
    scheduled_start: datetime
    actual_start: datetime | None = None
    ended_at: datetime | None = None
    vod_url: str | None = None
    tournament_id: int | None = None
    streamer_id: int


class StreamCreate(StreamBase):
    pass


class StreamUpdate(BaseModel):
    title: str | None = None
    stream_url: str | None = None
    platform: str | None = None
    status: str | None = None
    viewer_count_peak: int | None = None
    scheduled_start: datetime | None = None
    actual_start: datetime | None = None
    ended_at: datetime | None = None
    vod_url: str | None = None
    tournament_id: int | None = None
    streamer_id: int | None = None


class StreamRead(StreamBase):
    id: int
    model_config = ConfigDict(from_attributes=True)
