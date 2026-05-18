from typing import Sequence

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db import get_db
from .models import Season, Tournament, TournamentJudge, TournamentRegistration, TournamentRound, Match, Game, TournamentPrize, AwardedPrize
from .schemas import SeasonCreate, SeasonUpdate, SeasonRead, TournamentCreate, TournamentUpdate, TournamentRead, TournamentJudgeCreate, TournamentJudgeUpdate, TournamentJudgeRead, TournamentRegistrationCreate, TournamentRegistrationUpdate, TournamentRegistrationRead, TournamentRoundCreate, TournamentRoundUpdate, TournamentRoundRead, MatchCreate, MatchUpdate, MatchRead, GameCreate, GameUpdate, GameRead, TournamentPrizeCreate, TournamentPrizeUpdate, TournamentPrizeRead, AwardedPrizeCreate, AwardedPrizeUpdate, AwardedPrizeRead

def _validate_season(obj: Season) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_rules())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_season = APIRouter(prefix="/api/seasons", tags=["Season"])

@router_season.get("", response_model=list[SeasonRead])
def list_seasons(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Season]:
    return db.query(Season).offset(skip).limit(limit).all()

@router_season.post("", response_model=SeasonRead, status_code=status.HTTP_201_CREATED)
def create_season(data: SeasonCreate, db: Session = Depends(get_db)) -> Season:
    obj = Season(**data.model_dump(exclude_unset=True))
    _validate_season(obj)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_season.get("/{item_id}", response_model=SeasonRead)
def get_season(item_id: int, db: Session = Depends(get_db)) -> Season:
    obj = db.query(Season).filter(Season.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Season not found")
    return obj

@router_season.put("/{item_id}", response_model=SeasonRead)
def update_season(item_id: int, data: SeasonUpdate, db: Session = Depends(get_db)) -> Season:
    obj = db.query(Season).filter(Season.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Season not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    _validate_season(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_season.patch("/{item_id}", response_model=SeasonRead)
def patch_season(item_id: int, data: SeasonUpdate, db: Session = Depends(get_db)) -> Season:
    return update_season(item_id, data, db)

@router_season.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_season(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(Season).filter(Season.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Season not found")
    db.delete(obj)
    db.commit()

@router_season.post("/{item_id}/activate", status_code=status.HTTP_204_NO_CONTENT)
def activate_season(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Season).filter(Season.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Season not found")
    obj.activate()
    db.commit()

@router_season.post("/{item_id}/deactivate", status_code=status.HTTP_204_NO_CONTENT)
def deactivate_season(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Season).filter(Season.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Season not found")
    obj.deactivate()
    db.commit()

@router_season.post("/{item_id}/finalize", status_code=status.HTTP_204_NO_CONTENT)
def finalize_rewards_season(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Season).filter(Season.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Season not found")
    obj.finalize_rewards()
    db.commit()

def _validate_tournament(obj: Tournament) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_rules())
    errors.extend(obj.validate_implies())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_tournament = APIRouter(prefix="/api/tournaments", tags=["Tournament"])

@router_tournament.get("", response_model=list[TournamentRead])
def list_tournaments(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Tournament]:
    return db.query(Tournament).offset(skip).limit(limit).all()

@router_tournament.post("", response_model=TournamentRead, status_code=status.HTTP_201_CREATED)
def create_tournament(data: TournamentCreate, db: Session = Depends(get_db)) -> Tournament:
    obj = Tournament(**data.model_dump(exclude_unset=True))
    _validate_tournament(obj)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_tournament.get("/{item_id}", response_model=TournamentRead)
def get_tournament(item_id: int, db: Session = Depends(get_db)) -> Tournament:
    obj = db.query(Tournament).filter(Tournament.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Tournament not found")
    return obj

@router_tournament.put("/{item_id}", response_model=TournamentRead)
def update_tournament(item_id: int, data: TournamentUpdate, db: Session = Depends(get_db)) -> Tournament:
    obj = db.query(Tournament).filter(Tournament.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Tournament not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    _validate_tournament(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_tournament.patch("/{item_id}", response_model=TournamentRead)
def patch_tournament(item_id: int, data: TournamentUpdate, db: Session = Depends(get_db)) -> Tournament:
    return update_tournament(item_id, data, db)

@router_tournament.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_tournament(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(Tournament).filter(Tournament.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Tournament not found")
    db.delete(obj)
    db.commit()

@router_tournament.post("/{item_id}/start", status_code=status.HTTP_204_NO_CONTENT)
def start_tournament(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Tournament).filter(Tournament.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Tournament not found")
    obj.start()
    db.commit()

@router_tournament.post("/{item_id}/cancel", status_code=status.HTTP_204_NO_CONTENT)
def cancel_tournament(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Tournament).filter(Tournament.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Tournament not found")
    obj.cancel()
    db.commit()

@router_tournament.post("/{item_id}/complete", status_code=status.HTTP_204_NO_CONTENT)
def complete_tournament(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Tournament).filter(Tournament.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Tournament not found")
    obj.complete()
    db.commit()

@router_tournament.post("/{item_id}/rounds", status_code=status.HTTP_204_NO_CONTENT)
def generate_round_tournament(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Tournament).filter(Tournament.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Tournament not found")
    obj.generate_round()
    db.commit()

@router_tournament.get("/{item_id}/prizes", response_model=float)
def calculate_prize_distribution_tournament(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Tournament).filter(Tournament.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Tournament not found")
    result = obj.calculate_prize_distribution()
    db.commit()
    return result

router_tournament_judge = APIRouter(prefix="/api/tournament_judges", tags=["Tournament Judge"])

@router_tournament_judge.get("", response_model=list[TournamentJudgeRead])
def list_tournament_judges(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[TournamentJudge]:
    return db.query(TournamentJudge).offset(skip).limit(limit).all()

@router_tournament_judge.post("", response_model=TournamentJudgeRead, status_code=status.HTTP_201_CREATED)
def create_tournament_judge(data: TournamentJudgeCreate, db: Session = Depends(get_db)) -> TournamentJudge:
    obj = TournamentJudge(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_tournament_judge.get("/{item_id}", response_model=TournamentJudgeRead)
def get_tournament_judge(item_id: int, db: Session = Depends(get_db)) -> TournamentJudge:
    obj = db.query(TournamentJudge).filter(TournamentJudge.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TournamentJudge not found")
    return obj

@router_tournament_judge.put("/{item_id}", response_model=TournamentJudgeRead)
def update_tournament_judge(item_id: int, data: TournamentJudgeUpdate, db: Session = Depends(get_db)) -> TournamentJudge:
    obj = db.query(TournamentJudge).filter(TournamentJudge.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TournamentJudge not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_tournament_judge.patch("/{item_id}", response_model=TournamentJudgeRead)
def patch_tournament_judge(item_id: int, data: TournamentJudgeUpdate, db: Session = Depends(get_db)) -> TournamentJudge:
    return update_tournament_judge(item_id, data, db)

@router_tournament_judge.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_tournament_judge(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(TournamentJudge).filter(TournamentJudge.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TournamentJudge not found")
    db.delete(obj)
    db.commit()

router_tournament_registration = APIRouter(prefix="/api/tournament_registrations", tags=["Tournament Registration"])

@router_tournament_registration.get("", response_model=list[TournamentRegistrationRead])
def list_tournament_registrations(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[TournamentRegistration]:
    return db.query(TournamentRegistration).offset(skip).limit(limit).all()

@router_tournament_registration.post("", response_model=TournamentRegistrationRead, status_code=status.HTTP_201_CREATED)
def create_tournament_registration(data: TournamentRegistrationCreate, db: Session = Depends(get_db)) -> TournamentRegistration:
    obj = TournamentRegistration(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_tournament_registration.get("/{item_id}", response_model=TournamentRegistrationRead)
def get_tournament_registration(item_id: int, db: Session = Depends(get_db)) -> TournamentRegistration:
    obj = db.query(TournamentRegistration).filter(TournamentRegistration.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TournamentRegistration not found")
    return obj

@router_tournament_registration.put("/{item_id}", response_model=TournamentRegistrationRead)
def update_tournament_registration(item_id: int, data: TournamentRegistrationUpdate, db: Session = Depends(get_db)) -> TournamentRegistration:
    obj = db.query(TournamentRegistration).filter(TournamentRegistration.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TournamentRegistration not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_tournament_registration.patch("/{item_id}", response_model=TournamentRegistrationRead)
def patch_tournament_registration(item_id: int, data: TournamentRegistrationUpdate, db: Session = Depends(get_db)) -> TournamentRegistration:
    return update_tournament_registration(item_id, data, db)

@router_tournament_registration.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_tournament_registration(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(TournamentRegistration).filter(TournamentRegistration.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TournamentRegistration not found")
    db.delete(obj)
    db.commit()

@router_tournament_registration.post("/{item_id}/api/registrations/{id}/withdraw", status_code=status.HTTP_204_NO_CONTENT)
def withdraw_tournament_registration(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(TournamentRegistration).filter(TournamentRegistration.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TournamentRegistration not found")
    obj.withdraw()
    db.commit()

@router_tournament_registration.post("/{item_id}/api/registrations/{id}/disqualify", status_code=status.HTTP_204_NO_CONTENT)
def disqualify_tournament_registration(item_id: int, body: dict = {}, db: Session = Depends(get_db)):
    obj = db.query(TournamentRegistration).filter(TournamentRegistration.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TournamentRegistration not found")
    obj.disqualify(body.get("reason"))
    db.commit()

@router_tournament_registration.post("/{item_id}/api/registrations/{id}/promote", status_code=status.HTTP_204_NO_CONTENT)
def promote_from_waitlist_tournament_registration(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(TournamentRegistration).filter(TournamentRegistration.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TournamentRegistration not found")
    obj.promote_from_waitlist()
    db.commit()

def _validate_tournament_round(obj: TournamentRound) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_implies())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_tournament_round = APIRouter(prefix="/api/tournament_rounds", tags=["Tournament Round"])

@router_tournament_round.get("", response_model=list[TournamentRoundRead])
def list_tournament_rounds(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[TournamentRound]:
    return db.query(TournamentRound).offset(skip).limit(limit).all()

@router_tournament_round.post("", response_model=TournamentRoundRead, status_code=status.HTTP_201_CREATED)
def create_tournament_round(data: TournamentRoundCreate, db: Session = Depends(get_db)) -> TournamentRound:
    obj = TournamentRound(**data.model_dump(exclude_unset=True))
    _validate_tournament_round(obj)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_tournament_round.get("/{item_id}", response_model=TournamentRoundRead)
def get_tournament_round(item_id: int, db: Session = Depends(get_db)) -> TournamentRound:
    obj = db.query(TournamentRound).filter(TournamentRound.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TournamentRound not found")
    return obj

@router_tournament_round.put("/{item_id}", response_model=TournamentRoundRead)
def update_tournament_round(item_id: int, data: TournamentRoundUpdate, db: Session = Depends(get_db)) -> TournamentRound:
    obj = db.query(TournamentRound).filter(TournamentRound.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TournamentRound not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    _validate_tournament_round(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_tournament_round.patch("/{item_id}", response_model=TournamentRoundRead)
def patch_tournament_round(item_id: int, data: TournamentRoundUpdate, db: Session = Depends(get_db)) -> TournamentRound:
    return update_tournament_round(item_id, data, db)

@router_tournament_round.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_tournament_round(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(TournamentRound).filter(TournamentRound.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TournamentRound not found")
    db.delete(obj)
    db.commit()

@router_tournament_round.post("/{item_id}/api/rounds/{id}/start", status_code=status.HTTP_204_NO_CONTENT)
def start_tournament_round(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(TournamentRound).filter(TournamentRound.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TournamentRound not found")
    obj.start()
    db.commit()

@router_tournament_round.post("/{item_id}/api/rounds/{id}/complete", status_code=status.HTTP_204_NO_CONTENT)
def complete_tournament_round(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(TournamentRound).filter(TournamentRound.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TournamentRound not found")
    obj.complete()
    db.commit()

@router_tournament_round.post("/{item_id}/api/rounds/{id}/pairings", status_code=status.HTTP_204_NO_CONTENT)
def generate_pairings_tournament_round(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(TournamentRound).filter(TournamentRound.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TournamentRound not found")
    obj.generate_pairings()
    db.commit()

def _validate_match(obj: Match) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_rules())
    errors.extend(obj.validate_implies())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_match = APIRouter(prefix="/api/matches", tags=["Match"])

@router_match.get("", response_model=list[MatchRead])
def list_matches(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Match]:
    return db.query(Match).offset(skip).limit(limit).all()

@router_match.post("", response_model=MatchRead, status_code=status.HTTP_201_CREATED)
def create_match(data: MatchCreate, db: Session = Depends(get_db)) -> Match:
    obj = Match(**data.model_dump(exclude_unset=True))
    _validate_match(obj)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_match.get("/{item_id}", response_model=MatchRead)
def get_match(item_id: int, db: Session = Depends(get_db)) -> Match:
    obj = db.query(Match).filter(Match.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Match not found")
    return obj

@router_match.put("/{item_id}", response_model=MatchRead)
def update_match(item_id: int, data: MatchUpdate, db: Session = Depends(get_db)) -> Match:
    obj = db.query(Match).filter(Match.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Match not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    _validate_match(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_match.patch("/{item_id}", response_model=MatchRead)
def patch_match(item_id: int, data: MatchUpdate, db: Session = Depends(get_db)) -> Match:
    return update_match(item_id, data, db)

@router_match.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_match(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(Match).filter(Match.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Match not found")
    db.delete(obj)
    db.commit()

@router_match.post("/{item_id}/record", status_code=status.HTTP_204_NO_CONTENT)
def record_result_match(item_id: int, body: dict = {}, db: Session = Depends(get_db)):
    obj = db.query(Match).filter(Match.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Match not found")
    obj.record_result(body.get("p1_wins"), body.get("p2_wins"))
    db.commit()

@router_match.get("/{item_id}/winner", response_model=bool)
def determine_winner_match(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Match).filter(Match.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Match not found")
    result = obj.determine_winner()
    db.commit()
    return result

@router_match.post("/{item_id}/draw", status_code=status.HTTP_204_NO_CONTENT)
def draw_match(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Match).filter(Match.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Match not found")
    obj.draw()
    db.commit()

def _validate_game(obj: Game) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_rules())
    errors.extend(obj.validate_implies())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_game = APIRouter(prefix="/api/games", tags=["Game"])

@router_game.get("", response_model=list[GameRead])
def list_games(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Game]:
    return db.query(Game).offset(skip).limit(limit).all()

@router_game.post("", response_model=GameRead, status_code=status.HTTP_201_CREATED)
def create_game(data: GameCreate, db: Session = Depends(get_db)) -> Game:
    obj = Game(**data.model_dump(exclude_unset=True))
    _validate_game(obj)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_game.get("/{item_id}", response_model=GameRead)
def get_game(item_id: int, db: Session = Depends(get_db)) -> Game:
    obj = db.query(Game).filter(Game.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Game not found")
    return obj

@router_game.put("/{item_id}", response_model=GameRead)
def update_game(item_id: int, data: GameUpdate, db: Session = Depends(get_db)) -> Game:
    obj = db.query(Game).filter(Game.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Game not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    _validate_game(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_game.patch("/{item_id}", response_model=GameRead)
def patch_game(item_id: int, data: GameUpdate, db: Session = Depends(get_db)) -> Game:
    return update_game(item_id, data, db)

@router_game.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_game(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(Game).filter(Game.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Game not found")
    db.delete(obj)
    db.commit()

@router_game.post("/{item_id}/winner", status_code=status.HTTP_204_NO_CONTENT)
def record_winner_game(item_id: int, body: dict = {}, db: Session = Depends(get_db)):
    obj = db.query(Game).filter(Game.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Game not found")
    obj.record_winner(body.get("winner_side"))
    db.commit()

def _validate_tournament_prize(obj: TournamentPrize) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_rules())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_tournament_prize = APIRouter(prefix="/api/tournament_prizes", tags=["Tournament Prize"])

@router_tournament_prize.get("", response_model=list[TournamentPrizeRead])
def list_tournament_prizes(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[TournamentPrize]:
    return db.query(TournamentPrize).offset(skip).limit(limit).all()

@router_tournament_prize.post("", response_model=TournamentPrizeRead, status_code=status.HTTP_201_CREATED)
def create_tournament_prize(data: TournamentPrizeCreate, db: Session = Depends(get_db)) -> TournamentPrize:
    obj = TournamentPrize(**data.model_dump(exclude_unset=True))
    _validate_tournament_prize(obj)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_tournament_prize.get("/{item_id}", response_model=TournamentPrizeRead)
def get_tournament_prize(item_id: int, db: Session = Depends(get_db)) -> TournamentPrize:
    obj = db.query(TournamentPrize).filter(TournamentPrize.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TournamentPrize not found")
    return obj

@router_tournament_prize.put("/{item_id}", response_model=TournamentPrizeRead)
def update_tournament_prize(item_id: int, data: TournamentPrizeUpdate, db: Session = Depends(get_db)) -> TournamentPrize:
    obj = db.query(TournamentPrize).filter(TournamentPrize.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TournamentPrize not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    _validate_tournament_prize(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_tournament_prize.patch("/{item_id}", response_model=TournamentPrizeRead)
def patch_tournament_prize(item_id: int, data: TournamentPrizeUpdate, db: Session = Depends(get_db)) -> TournamentPrize:
    return update_tournament_prize(item_id, data, db)

@router_tournament_prize.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_tournament_prize(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(TournamentPrize).filter(TournamentPrize.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TournamentPrize not found")
    db.delete(obj)
    db.commit()

def _validate_awarded_prize(obj: AwardedPrize) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_rules())
    errors.extend(obj.validate_implies())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_awarded_prize = APIRouter(prefix="/api/awarded_prizes", tags=["Awarded Prize"])

@router_awarded_prize.get("", response_model=list[AwardedPrizeRead])
def list_awarded_prizes(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[AwardedPrize]:
    return db.query(AwardedPrize).offset(skip).limit(limit).all()

@router_awarded_prize.post("", response_model=AwardedPrizeRead, status_code=status.HTTP_201_CREATED)
def create_awarded_prize(data: AwardedPrizeCreate, db: Session = Depends(get_db)) -> AwardedPrize:
    obj = AwardedPrize(**data.model_dump(exclude_unset=True))
    _validate_awarded_prize(obj)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_awarded_prize.get("/{item_id}", response_model=AwardedPrizeRead)
def get_awarded_prize(item_id: int, db: Session = Depends(get_db)) -> AwardedPrize:
    obj = db.query(AwardedPrize).filter(AwardedPrize.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="AwardedPrize not found")
    return obj

@router_awarded_prize.put("/{item_id}", response_model=AwardedPrizeRead)
def update_awarded_prize(item_id: int, data: AwardedPrizeUpdate, db: Session = Depends(get_db)) -> AwardedPrize:
    obj = db.query(AwardedPrize).filter(AwardedPrize.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="AwardedPrize not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    _validate_awarded_prize(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_awarded_prize.patch("/{item_id}", response_model=AwardedPrizeRead)
def patch_awarded_prize(item_id: int, data: AwardedPrizeUpdate, db: Session = Depends(get_db)) -> AwardedPrize:
    return update_awarded_prize(item_id, data, db)

@router_awarded_prize.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_awarded_prize(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(AwardedPrize).filter(AwardedPrize.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="AwardedPrize not found")
    db.delete(obj)
    db.commit()
