from typing import Sequence

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db import get_db
from .models import DraftSession, DraftParticipant, DraftPick, Article, ArticleTag, ArticleTagAssignment, ArticleComment, Stream
from .schemas import DraftSessionCreate, DraftSessionUpdate, DraftSessionRead, DraftParticipantCreate, DraftParticipantUpdate, DraftParticipantRead, DraftPickCreate, DraftPickUpdate, DraftPickRead, ArticleCreate, ArticleUpdate, ArticleRead, ArticleTagCreate, ArticleTagUpdate, ArticleTagRead, ArticleTagAssignmentCreate, ArticleTagAssignmentUpdate, ArticleTagAssignmentRead, ArticleCommentCreate, ArticleCommentUpdate, ArticleCommentRead, StreamCreate, StreamUpdate, StreamRead

router_draft_session = APIRouter(prefix="/api/draft_sessions", tags=["Draft Session"])

@router_draft_session.get("", response_model=list[DraftSessionRead])
def list_draft_sessions(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[DraftSession]:
    return db.query(DraftSession).offset(skip).limit(limit).all()

@router_draft_session.post("", response_model=DraftSessionRead, status_code=status.HTTP_201_CREATED)
def create_draft_session(data: DraftSessionCreate, db: Session = Depends(get_db)) -> DraftSession:
    obj = DraftSession(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_draft_session.get("/{item_id}", response_model=DraftSessionRead)
def get_draft_session(item_id: int, db: Session = Depends(get_db)) -> DraftSession:
    obj = db.query(DraftSession).filter(DraftSession.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DraftSession not found")
    return obj

@router_draft_session.put("/{item_id}", response_model=DraftSessionRead)
def update_draft_session(item_id: int, data: DraftSessionUpdate, db: Session = Depends(get_db)) -> DraftSession:
    obj = db.query(DraftSession).filter(DraftSession.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DraftSession not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_draft_session.patch("/{item_id}", response_model=DraftSessionRead)
def patch_draft_session(item_id: int, data: DraftSessionUpdate, db: Session = Depends(get_db)) -> DraftSession:
    return update_draft_session(item_id, data, db)

@router_draft_session.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_draft_session(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(DraftSession).filter(DraftSession.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DraftSession not found")
    db.delete(obj)
    db.commit()

@router_draft_session.post("/{item_id}/api/draft-sessions/{id}/start", status_code=status.HTTP_204_NO_CONTENT)
def start_draft_session(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(DraftSession).filter(DraftSession.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DraftSession not found")
    obj.start()
    db.commit()

@router_draft_session.post("/{item_id}/api/draft-sessions/{id}/abandon", status_code=status.HTTP_204_NO_CONTENT)
def abandon_draft_session(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(DraftSession).filter(DraftSession.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DraftSession not found")
    obj.abandon()
    db.commit()

@router_draft_session.post("/{item_id}/api/draft-sessions/{id}/complete", status_code=status.HTTP_204_NO_CONTENT)
def complete_draft_session(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(DraftSession).filter(DraftSession.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DraftSession not found")
    obj.complete()
    db.commit()

router_draft_participant = APIRouter(prefix="/api/draft_participants", tags=["Draft Participant"])

@router_draft_participant.get("", response_model=list[DraftParticipantRead])
def list_draft_participants(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[DraftParticipant]:
    return db.query(DraftParticipant).offset(skip).limit(limit).all()

@router_draft_participant.post("", response_model=DraftParticipantRead, status_code=status.HTTP_201_CREATED)
def create_draft_participant(data: DraftParticipantCreate, db: Session = Depends(get_db)) -> DraftParticipant:
    obj = DraftParticipant(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_draft_participant.get("/{item_id}", response_model=DraftParticipantRead)
def get_draft_participant(item_id: int, db: Session = Depends(get_db)) -> DraftParticipant:
    obj = db.query(DraftParticipant).filter(DraftParticipant.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DraftParticipant not found")
    return obj

@router_draft_participant.put("/{item_id}", response_model=DraftParticipantRead)
def update_draft_participant(item_id: int, data: DraftParticipantUpdate, db: Session = Depends(get_db)) -> DraftParticipant:
    obj = db.query(DraftParticipant).filter(DraftParticipant.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DraftParticipant not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_draft_participant.patch("/{item_id}", response_model=DraftParticipantRead)
def patch_draft_participant(item_id: int, data: DraftParticipantUpdate, db: Session = Depends(get_db)) -> DraftParticipant:
    return update_draft_participant(item_id, data, db)

@router_draft_participant.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_draft_participant(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(DraftParticipant).filter(DraftParticipant.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DraftParticipant not found")
    db.delete(obj)
    db.commit()

@router_draft_participant.post("/{item_id}/api/draft-participants/{id}/pick", status_code=status.HTTP_204_NO_CONTENT)
def pick_card_draft_participant(item_id: int, body: dict = {}, db: Session = Depends(get_db)):
    obj = db.query(DraftParticipant).filter(DraftParticipant.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DraftParticipant not found")
    obj.pick_card(body.get("card_id"), body.get("pack_number"))
    db.commit()

router_draft_pick = APIRouter(prefix="/api/draft_picks", tags=["Draft Pick"])

@router_draft_pick.get("", response_model=list[DraftPickRead])
def list_draft_picks(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[DraftPick]:
    return db.query(DraftPick).offset(skip).limit(limit).all()

@router_draft_pick.post("", response_model=DraftPickRead, status_code=status.HTTP_201_CREATED)
def create_draft_pick(data: DraftPickCreate, db: Session = Depends(get_db)) -> DraftPick:
    obj = DraftPick(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_draft_pick.get("/{item_id}", response_model=DraftPickRead)
def get_draft_pick(item_id: int, db: Session = Depends(get_db)) -> DraftPick:
    obj = db.query(DraftPick).filter(DraftPick.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DraftPick not found")
    return obj

@router_draft_pick.put("/{item_id}", response_model=DraftPickRead)
def update_draft_pick(item_id: int, data: DraftPickUpdate, db: Session = Depends(get_db)) -> DraftPick:
    obj = db.query(DraftPick).filter(DraftPick.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DraftPick not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_draft_pick.patch("/{item_id}", response_model=DraftPickRead)
def patch_draft_pick(item_id: int, data: DraftPickUpdate, db: Session = Depends(get_db)) -> DraftPick:
    return update_draft_pick(item_id, data, db)

@router_draft_pick.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_draft_pick(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(DraftPick).filter(DraftPick.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="DraftPick not found")
    db.delete(obj)
    db.commit()

def _validate_article(obj: Article) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_implies())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_article = APIRouter(prefix="/api/articles", tags=["Article"])

@router_article.get("", response_model=list[ArticleRead])
def list_articles(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Article]:
    return db.query(Article).offset(skip).limit(limit).all()

@router_article.post("", response_model=ArticleRead, status_code=status.HTTP_201_CREATED)
def create_article(data: ArticleCreate, db: Session = Depends(get_db)) -> Article:
    obj = Article(**data.model_dump(exclude_unset=True))
    _validate_article(obj)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_article.get("/{item_id}", response_model=ArticleRead)
def get_article(item_id: int, db: Session = Depends(get_db)) -> Article:
    obj = db.query(Article).filter(Article.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Article not found")
    return obj

@router_article.put("/{item_id}", response_model=ArticleRead)
def update_article(item_id: int, data: ArticleUpdate, db: Session = Depends(get_db)) -> Article:
    obj = db.query(Article).filter(Article.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Article not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    _validate_article(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_article.patch("/{item_id}", response_model=ArticleRead)
def patch_article(item_id: int, data: ArticleUpdate, db: Session = Depends(get_db)) -> Article:
    return update_article(item_id, data, db)

@router_article.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_article(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(Article).filter(Article.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Article not found")
    db.delete(obj)
    db.commit()

@router_article.post("/{item_id}/publish", status_code=status.HTTP_204_NO_CONTENT)
def publish_article(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Article).filter(Article.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Article not found")
    obj.publish()
    db.commit()

@router_article.post("/{item_id}/archive", status_code=status.HTTP_204_NO_CONTENT)
def archive_article(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Article).filter(Article.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Article not found")
    obj.archive()
    db.commit()

@router_article.post("/{item_id}/view", status_code=status.HTTP_204_NO_CONTENT)
def increment_view_article(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Article).filter(Article.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Article not found")
    obj.increment_view()
    db.commit()

router_article_tag = APIRouter(prefix="/api/article_tags", tags=["Article Tag"])

@router_article_tag.get("", response_model=list[ArticleTagRead])
def list_article_tags(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[ArticleTag]:
    return db.query(ArticleTag).offset(skip).limit(limit).all()

@router_article_tag.post("", response_model=ArticleTagRead, status_code=status.HTTP_201_CREATED)
def create_article_tag(data: ArticleTagCreate, db: Session = Depends(get_db)) -> ArticleTag:
    obj = ArticleTag(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_article_tag.get("/{item_id}", response_model=ArticleTagRead)
def get_article_tag(item_id: int, db: Session = Depends(get_db)) -> ArticleTag:
    obj = db.query(ArticleTag).filter(ArticleTag.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="ArticleTag not found")
    return obj

@router_article_tag.put("/{item_id}", response_model=ArticleTagRead)
def update_article_tag(item_id: int, data: ArticleTagUpdate, db: Session = Depends(get_db)) -> ArticleTag:
    obj = db.query(ArticleTag).filter(ArticleTag.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="ArticleTag not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_article_tag.patch("/{item_id}", response_model=ArticleTagRead)
def patch_article_tag(item_id: int, data: ArticleTagUpdate, db: Session = Depends(get_db)) -> ArticleTag:
    return update_article_tag(item_id, data, db)

@router_article_tag.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_article_tag(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(ArticleTag).filter(ArticleTag.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="ArticleTag not found")
    db.delete(obj)
    db.commit()

router_article_tag_assignment = APIRouter(prefix="/api/article_tag_assignments", tags=["Article Tag Assignment"])

@router_article_tag_assignment.get("", response_model=list[ArticleTagAssignmentRead])
def list_article_tag_assignments(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[ArticleTagAssignment]:
    return db.query(ArticleTagAssignment).offset(skip).limit(limit).all()

@router_article_tag_assignment.post("", response_model=ArticleTagAssignmentRead, status_code=status.HTTP_201_CREATED)
def create_article_tag_assignment(data: ArticleTagAssignmentCreate, db: Session = Depends(get_db)) -> ArticleTagAssignment:
    obj = ArticleTagAssignment(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_article_tag_assignment.get("/{item_id}", response_model=ArticleTagAssignmentRead)
def get_article_tag_assignment(item_id: int, db: Session = Depends(get_db)) -> ArticleTagAssignment:
    obj = db.query(ArticleTagAssignment).filter(ArticleTagAssignment.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="ArticleTagAssignment not found")
    return obj

@router_article_tag_assignment.put("/{item_id}", response_model=ArticleTagAssignmentRead)
def update_article_tag_assignment(item_id: int, data: ArticleTagAssignmentUpdate, db: Session = Depends(get_db)) -> ArticleTagAssignment:
    obj = db.query(ArticleTagAssignment).filter(ArticleTagAssignment.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="ArticleTagAssignment not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_article_tag_assignment.patch("/{item_id}", response_model=ArticleTagAssignmentRead)
def patch_article_tag_assignment(item_id: int, data: ArticleTagAssignmentUpdate, db: Session = Depends(get_db)) -> ArticleTagAssignment:
    return update_article_tag_assignment(item_id, data, db)

@router_article_tag_assignment.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_article_tag_assignment(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(ArticleTagAssignment).filter(ArticleTagAssignment.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="ArticleTagAssignment not found")
    db.delete(obj)
    db.commit()

router_article_comment = APIRouter(prefix="/api/article_comments", tags=["Article Comment"])

@router_article_comment.get("", response_model=list[ArticleCommentRead])
def list_article_comments(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[ArticleComment]:
    return db.query(ArticleComment).offset(skip).limit(limit).all()

@router_article_comment.post("", response_model=ArticleCommentRead, status_code=status.HTTP_201_CREATED)
def create_article_comment(data: ArticleCommentCreate, db: Session = Depends(get_db)) -> ArticleComment:
    obj = ArticleComment(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_article_comment.get("/{item_id}", response_model=ArticleCommentRead)
def get_article_comment(item_id: int, db: Session = Depends(get_db)) -> ArticleComment:
    obj = db.query(ArticleComment).filter(ArticleComment.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="ArticleComment not found")
    return obj

@router_article_comment.put("/{item_id}", response_model=ArticleCommentRead)
def update_article_comment(item_id: int, data: ArticleCommentUpdate, db: Session = Depends(get_db)) -> ArticleComment:
    obj = db.query(ArticleComment).filter(ArticleComment.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="ArticleComment not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_article_comment.patch("/{item_id}", response_model=ArticleCommentRead)
def patch_article_comment(item_id: int, data: ArticleCommentUpdate, db: Session = Depends(get_db)) -> ArticleComment:
    return update_article_comment(item_id, data, db)

@router_article_comment.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_article_comment(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(ArticleComment).filter(ArticleComment.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="ArticleComment not found")
    db.delete(obj)
    db.commit()

@router_article_comment.post("/{item_id}/api/comments/{id}/hide", status_code=status.HTTP_204_NO_CONTENT)
def hide_article_comment(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(ArticleComment).filter(ArticleComment.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="ArticleComment not found")
    obj.hide()
    db.commit()

@router_article_comment.post("/{item_id}/api/comments/{id}/unhide", status_code=status.HTTP_204_NO_CONTENT)
def unhide_article_comment(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(ArticleComment).filter(ArticleComment.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="ArticleComment not found")
    obj.unhide()
    db.commit()

def _validate_stream(obj: Stream) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_implies())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_stream = APIRouter(prefix="/api/streams", tags=["Stream"])

@router_stream.get("", response_model=list[StreamRead])
def list_streams(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Stream]:
    return db.query(Stream).offset(skip).limit(limit).all()

@router_stream.post("", response_model=StreamRead, status_code=status.HTTP_201_CREATED)
def create_stream(data: StreamCreate, db: Session = Depends(get_db)) -> Stream:
    obj = Stream(**data.model_dump(exclude_unset=True))
    _validate_stream(obj)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_stream.get("/{item_id}", response_model=StreamRead)
def get_stream(item_id: int, db: Session = Depends(get_db)) -> Stream:
    obj = db.query(Stream).filter(Stream.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Stream not found")
    return obj

@router_stream.put("/{item_id}", response_model=StreamRead)
def update_stream(item_id: int, data: StreamUpdate, db: Session = Depends(get_db)) -> Stream:
    obj = db.query(Stream).filter(Stream.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Stream not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    _validate_stream(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_stream.patch("/{item_id}", response_model=StreamRead)
def patch_stream(item_id: int, data: StreamUpdate, db: Session = Depends(get_db)) -> Stream:
    return update_stream(item_id, data, db)

@router_stream.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_stream(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(Stream).filter(Stream.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Stream not found")
    db.delete(obj)
    db.commit()

@router_stream.post("/{item_id}/live", status_code=status.HTTP_204_NO_CONTENT)
def go_live_stream(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Stream).filter(Stream.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Stream not found")
    obj.go_live()
    db.commit()

@router_stream.post("/{item_id}/end", status_code=status.HTTP_204_NO_CONTENT)
def end_stream(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Stream).filter(Stream.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Stream not found")
    obj.end()
    db.commit()

@router_stream.patch("/{item_id}/viewers", status_code=status.HTTP_204_NO_CONTENT)
def update_viewer_peak_stream(item_id: int, body: dict = {}, db: Session = Depends(get_db)):
    obj = db.query(Stream).filter(Stream.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Stream not found")
    obj.update_viewer_peak(body.get("count"))
    db.commit()
