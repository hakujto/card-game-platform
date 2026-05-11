from __future__ import annotations

from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict

class SeasonBase(BaseModel):
    name: str
    start_date: date
    end_date: date
    format: str
    is_active: bool
    reward_description: str | None = None


class SeasonCreate(SeasonBase):
    pass


class SeasonUpdate(BaseModel):
    name: str | None = None
    start_date: date | None = None
    end_date: date | None = None
    format: str | None = None
    is_active: bool | None = None
    reward_description: str | None = None


class SeasonRead(SeasonBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class TournamentBase(BaseModel):
    name: str
    description: str | None = None
    format: str
    tournament_type: str
    status: str
    max_players: int
    entry_fee: float
    prize_pool: float
    start_time: datetime
    end_time: datetime | None = None
    is_online: bool
    location: str | None = None
    rules_text: str | None = None
    created_at: datetime
    season_id: int
    organizer_id: int
    judges_ids: list[int] = []


class TournamentCreate(TournamentBase):
    pass


class TournamentUpdate(BaseModel):
    name: str | None = None
    description: str | None = None
    format: str | None = None
    tournament_type: str | None = None
    status: str | None = None
    max_players: int | None = None
    entry_fee: float | None = None
    prize_pool: float | None = None
    start_time: datetime | None = None
    end_time: datetime | None = None
    is_online: bool | None = None
    location: str | None = None
    rules_text: str | None = None
    created_at: datetime | None = None
    season_id: int | None = None
    organizer_id: int | None = None
    judges_ids: list[int] | None = None


class TournamentRead(TournamentBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class TournamentJudgeBase(BaseModel):
    role: str
    tournament_id: int
    player_id: int


class TournamentJudgeCreate(TournamentJudgeBase):
    pass


class TournamentJudgeUpdate(BaseModel):
    role: str | None = None
    tournament_id: int | None = None
    player_id: int | None = None


class TournamentJudgeRead(TournamentJudgeBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class TournamentRegistrationBase(BaseModel):
    status: str
    seed: int | None = None
    final_standing: int | None = None
    points_earned: int
    registered_at: datetime
    tournament_id: int
    player_id: int
    deck_id: int


class TournamentRegistrationCreate(TournamentRegistrationBase):
    pass


class TournamentRegistrationUpdate(BaseModel):
    status: str | None = None
    seed: int | None = None
    final_standing: int | None = None
    points_earned: int | None = None
    registered_at: datetime | None = None
    tournament_id: int | None = None
    player_id: int | None = None
    deck_id: int | None = None


class TournamentRegistrationRead(TournamentRegistrationBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class TournamentRoundBase(BaseModel):
    round_number: int
    status: str
    started_at: datetime | None = None
    ended_at: datetime | None = None
    time_limit_minutes: int
    tournament_id: int


class TournamentRoundCreate(TournamentRoundBase):
    pass


class TournamentRoundUpdate(BaseModel):
    round_number: int | None = None
    status: str | None = None
    started_at: datetime | None = None
    ended_at: datetime | None = None
    time_limit_minutes: int | None = None
    tournament_id: int | None = None


class TournamentRoundRead(TournamentRoundBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class MatchBase(BaseModel):
    table_number: int | None = None
    status: str
    player1_wins: int
    player2_wins: int
    started_at: datetime | None = None
    ended_at: datetime | None = None
    result_notes: str | None = None
    round_id: int | None = None
    player1_id: int
    player2_id: int | None = None


class MatchCreate(MatchBase):
    pass


class MatchUpdate(BaseModel):
    table_number: int | None = None
    status: str | None = None
    player1_wins: int | None = None
    player2_wins: int | None = None
    started_at: datetime | None = None
    ended_at: datetime | None = None
    result_notes: str | None = None
    round_id: int | None = None
    player1_id: int | None = None
    player2_id: int | None = None


class MatchRead(MatchBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class GameBase(BaseModel):
    game_number: int
    winner_side: str | None = None
    turns_played: int | None = None
    duration_seconds: int | None = None
    ended_by: str | None = None
    replay_url: str | None = None
    match_id: int
    winner_id: int | None = None


class GameCreate(GameBase):
    pass


class GameUpdate(BaseModel):
    game_number: int | None = None
    winner_side: str | None = None
    turns_played: int | None = None
    duration_seconds: int | None = None
    ended_by: str | None = None
    replay_url: str | None = None
    match_id: int | None = None
    winner_id: int | None = None


class GameRead(GameBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class TournamentPrizeBase(BaseModel):
    placement_from: int
    placement_to: int
    prize_type: str
    amount: float
    description: str | None = None
    packs_count: int | None = None
    season_points: int
    tournament_id: int


class TournamentPrizeCreate(TournamentPrizeBase):
    pass


class TournamentPrizeUpdate(BaseModel):
    placement_from: int | None = None
    placement_to: int | None = None
    prize_type: str | None = None
    amount: float | None = None
    description: str | None = None
    packs_count: int | None = None
    season_points: int | None = None
    tournament_id: int | None = None


class TournamentPrizeRead(TournamentPrizeBase):
    id: int
    model_config = ConfigDict(from_attributes=True)


class AwardedPrizeBase(BaseModel):
    final_placement: int
    awarded_at: datetime
    claimed: bool
    claimed_at: datetime | None = None
    prize_id: int
    player_id: int


class AwardedPrizeCreate(AwardedPrizeBase):
    pass


class AwardedPrizeUpdate(BaseModel):
    final_placement: int | None = None
    awarded_at: datetime | None = None
    claimed: bool | None = None
    claimed_at: datetime | None = None
    prize_id: int | None = None
    player_id: int | None = None


class AwardedPrizeRead(AwardedPrizeBase):
    id: int
    model_config = ConfigDict(from_attributes=True)
