from __future__ import annotations

from sqlalchemy import (
    Boolean, Column, Date, DateTime, Float, ForeignKey, Integer,
    JSON, Numeric, SmallInteger, String, Table, Text,
)
from sqlalchemy.orm import relationship

from app.db import Base

tournament_judges_assoc = Table(
    "tournament_judges_m2m",
    Base.metadata,
    Column("tournament_id", Integer, ForeignKey("tournament.id"), primary_key=True),
    Column("player_id", Integer, ForeignKey("player.id"), primary_key=True),
)

from typing import Literal

SeasonFormatType = Literal["Standard", "Extended", "Legacy", "Vintage", "Commander", "Draft"]

class Season(Base):
    __tablename__ = "season"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200))
    start_date = Column(Date)
    end_date = Column(Date)
    format = Column(String(20), default="Standard")
    is_active = Column(Boolean, default="false")
    reward_description = Column(Text, nullable=True)

    def activate(self):
        raise NotImplementedError("activate not implemented")

    def deactivate(self):
        raise NotImplementedError("deactivate not implemented")

    def finalize_rewards(self):
        raise NotImplementedError("finalize_rewards not implemented")

    def is_ongoing(self) -> bool:
        raise NotImplementedError("is_ongoing not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.end_date is None or (self.start_date is not None and self.end_date > self.start_date))):
            errors.append("Season end date must be after start date")
        return errors
    def __repr__(self) -> str:
        return f"<Season id={{self.id}}>"


from typing import Literal

TournamentFormatType = Literal["Standard", "Extended", "Legacy", "Vintage", "Commander", "Draft"]
TournamentTournamentTypeType = Literal["Swiss", "SingleElimination", "DoubleElimination", "RoundRobin"]
TournamentStatusType = Literal["Draft", "Registration", "Ongoing", "Completed", "Cancelled"]

class Tournament(Base):
    __tablename__ = "tournament"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200))
    description = Column(Text, nullable=True)
    format = Column(String(20), default="Standard")
    tournament_type = Column(String(20), default="Swiss")
    status = Column(String(20), default="Draft")
    max_players = Column(Integer)
    entry_fee = Column(Numeric, default="0")
    prize_pool = Column(Numeric, default="0")
    start_time = Column(DateTime)
    end_time = Column(DateTime, nullable=True)
    is_online = Column(Boolean, default="true")
    location = Column(String(300), nullable=True)
    rules_text = Column(Text, nullable=True)
    created_at = Column(DateTime)
    season_id = Column(Integer, ForeignKey("season.id"), nullable=False)
    season = relationship("Season", foreign_keys=[season_id])
    organizer_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    organizer = relationship("Player", foreign_keys=[organizer_id])
    judges = relationship("Player", secondary=tournament_judges_assoc)

    def start(self):
        raise NotImplementedError("start not implemented")

    def cancel(self):
        raise NotImplementedError("cancel not implemented")

    def complete(self):
        raise NotImplementedError("complete not implemented")

    def generate_round(self):
        raise NotImplementedError("generate_round not implemented")

    def calculate_prize_distribution(self) -> float:
        raise NotImplementedError("calculate_prize_distribution not implemented")

    def is_full(self) -> bool:
        raise NotImplementedError("is_full not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.max_players is None or (self.max_players >= 2 and self.max_players <= 512))):
            errors.append("Tournament must allow between 2 and 512 players")
        if not ((self.entry_fee is None or self.entry_fee >= 0)):
            errors.append("Entry fee must not be negative")
        if not ((self.prize_pool is None or self.prize_pool >= 0)):
            errors.append("Prize pool must not be negative")
        return errors

    def validate_implies(self) -> list[str]:
        errors = []
        if (self.end_time is not None) and not ((self.end_time is None or (self.start_time is not None and self.end_time > self.start_time))):
            errors.append("End time must be after start time")
        return errors
    def __repr__(self) -> str:
        return f"<Tournament id={{self.id}}>"


from typing import Literal

TournamentJudgeRoleType = Literal["HeadJudge", "Judge", "ScorekeeperJudge"]

class TournamentJudge(Base):
    __tablename__ = "tournament_judge"

    id = Column(Integer, primary_key=True, index=True)
    role = Column(String(20), default="Judge")
    tournament_id = Column(Integer, ForeignKey("tournament.id"), nullable=False)
    tournament = relationship("Tournament", foreign_keys=[tournament_id])
    player_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    player = relationship("Player", foreign_keys=[player_id])
    def __repr__(self) -> str:
        return f"<TournamentJudge id={{self.id}}>"


from typing import Literal

TournamentRegistrationStatusType = Literal["Registered", "Waitlisted", "Withdrawn", "Disqualified"]

class TournamentRegistration(Base):
    __tablename__ = "tournament_registration"

    id = Column(Integer, primary_key=True, index=True)
    status = Column(String(20), default="Registered")
    seed = Column(Integer, nullable=True)
    final_standing = Column(Integer, nullable=True)
    points_earned = Column(Integer, default="0")
    registered_at = Column(DateTime)
    tournament_id = Column(Integer, ForeignKey("tournament.id"), nullable=False)
    tournament = relationship("Tournament", foreign_keys=[tournament_id])
    player_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    player = relationship("Player", foreign_keys=[player_id])
    deck_id = Column(Integer, ForeignKey("deck.id"), nullable=False)
    deck = relationship("Deck", foreign_keys=[deck_id])

    def withdraw(self):
        raise NotImplementedError("withdraw not implemented")

    def disqualify(self, reason: str):
        raise NotImplementedError("disqualify not implemented")

    def promote_from_waitlist(self):
        raise NotImplementedError("promote_from_waitlist not implemented")

    def __repr__(self) -> str:
        return f"<TournamentRegistration id={{self.id}}>"


from typing import Literal

TournamentRoundStatusType = Literal["Pending", "Active", "Completed"]

class TournamentRound(Base):
    __tablename__ = "tournament_round"

    id = Column(Integer, primary_key=True, index=True)
    round_number = Column(Integer)
    status = Column(String(20), default="Pending")
    started_at = Column(DateTime, nullable=True)
    ended_at = Column(DateTime, nullable=True)
    time_limit_minutes = Column(Integer, default="50")
    tournament_id = Column(Integer, ForeignKey("tournament.id"), nullable=False)
    tournament = relationship("Tournament", foreign_keys=[tournament_id])

    def start(self):
        raise NotImplementedError("start not implemented")

    def complete(self):
        raise NotImplementedError("complete not implemented")

    def generate_pairings(self):
        raise NotImplementedError("generate_pairings not implemented")

    def is_time_expired(self) -> bool:
        raise NotImplementedError("is_time_expired not implemented")


    def validate_implies(self) -> list[str]:
        errors = []
        if (self.ended_at is not None) and not ((self.ended_at is None or (self.started_at is not None and self.ended_at > self.started_at))):
            errors.append("Round end time must be after start time")
        return errors
    def __repr__(self) -> str:
        return f"<TournamentRound id={{self.id}}>"


from typing import Literal

MatchStatusType = Literal["Pending", "Active", "Completed", "BYE", "Draw"]

class Match(Base):
    __tablename__ = "match"

    id = Column(Integer, primary_key=True, index=True)
    table_number = Column(Integer, nullable=True)
    status = Column(String(20), default="Pending")
    player1_wins = Column(Integer, default="0")
    player2_wins = Column(Integer, default="0")
    started_at = Column(DateTime, nullable=True)
    ended_at = Column(DateTime, nullable=True)
    result_notes = Column(Text, nullable=True)
    round_id = Column(Integer, ForeignKey("tournament_round.id"), nullable=True)
    round = relationship("TournamentRound", foreign_keys=[round_id])
    player1_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    player1 = relationship("Player", foreign_keys=[player1_id])
    player2_id = Column(Integer, ForeignKey("player.id"), nullable=True)
    player2 = relationship("Player", foreign_keys=[player2_id])

    def record_result(self, p1_wins: int, p2_wins: int):
        raise NotImplementedError("record_result not implemented")

    def determine_winner(self) -> bool:
        raise NotImplementedError("determine_winner not implemented")

    def draw(self):
        raise NotImplementedError("draw not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not (((self.player1_wins is None or self.player1_wins >= 0) and (self.player2_wins is None or self.player2_wins >= 0))):
            errors.append("Win counts must not be negative")
        if not (((self.player1_wins is None or (self.player1_wins >= 0 and self.player1_wins <= 2)) and (self.player2_wins is None or (self.player2_wins >= 0 and self.player2_wins <= 2)))):
            errors.append("Win counts cannot exceed 2 in a best-of-3 match")
        return errors

    def validate_implies(self) -> list[str]:
        errors = []
        if (self.status == "BYE") and not (self.player2_id is None):
            errors.append("BYE match must not have a second player")
        return errors
    def __repr__(self) -> str:
        return f"<Match id={{self.id}}>"


from typing import Literal

GameWinnerSideType = Literal["Player1", "Player2", "Draw"]
GameEndedByType = Literal["Normal", "Timeout", "Concession", "DrawOffer"]

class Game(Base):
    __tablename__ = "game"

    id = Column(Integer, primary_key=True, index=True)
    game_number = Column(Integer)
    winner_side = Column(String(20), nullable=True)
    turns_played = Column(Integer, nullable=True)
    duration_seconds = Column(Integer, nullable=True)
    ended_by = Column(String(20), nullable=True)
    replay_url = Column(String(200), nullable=True)
    match_id = Column(Integer, ForeignKey("match.id"), nullable=False)
    match = relationship("Match", foreign_keys=[match_id])
    winner_id = Column(Integer, ForeignKey("player.id"), nullable=True)
    winner = relationship("Player", foreign_keys=[winner_id])

    def record_winner(self, winner_side: str):
        raise NotImplementedError("record_winner not implemented")

    def duration_minutes(self) -> float:
        raise NotImplementedError("duration_minutes not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.game_number is None or (self.game_number >= 1 and self.game_number <= 3))):
            errors.append("Game number must be between 1 and 3 (best-of-3)")
        return errors

    def validate_implies(self) -> list[str]:
        errors = []
        if (self.turns_played is not None) and not ((self.turns_played is None or self.turns_played > 0)):
            errors.append("Turns played must be greater than zero")
        if (self.duration_seconds is not None) and not ((self.duration_seconds is None or self.duration_seconds > 0)):
            errors.append("Game duration must be greater than zero")
        return errors
    def __repr__(self) -> str:
        return f"<Game id={{self.id}}>"


from typing import Literal

TournamentPrizePrizeTypeType = Literal["Currency", "Cards", "BoosterPacks", "Trophy", "SeasonPoints", "Mixed"]

class TournamentPrize(Base):
    __tablename__ = "tournament_prize"

    id = Column(Integer, primary_key=True, index=True)
    placement_from = Column(Integer)
    placement_to = Column(Integer)
    prize_type = Column(String(20))
    amount = Column(Numeric, default="0")
    description = Column(Text, nullable=True)
    packs_count = Column(Integer, nullable=True)
    season_points = Column(Integer, default="0")
    tournament_id = Column(Integer, ForeignKey("tournament.id"), nullable=False)
    tournament = relationship("Tournament", foreign_keys=[tournament_id])

    def applies_to_placement(self, placement: int) -> bool:
        raise NotImplementedError("applies_to_placement not implemented")


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.placement_to is None or (self.placement_from is not None and self.placement_to >= self.placement_from))):
            errors.append("placement_to must be greater than or equal to placement_from")
        if not ((self.placement_from is None or self.placement_from > 0)):
            errors.append("placement_from must be greater than zero")
        if not ((self.amount is None or self.amount >= 0)):
            errors.append("Prize amount must not be negative")
        return errors
    def __repr__(self) -> str:
        return f"<TournamentPrize id={{self.id}}>"


class AwardedPrize(Base):
    __tablename__ = "awarded_prize"

    id = Column(Integer, primary_key=True, index=True)
    final_placement = Column(Integer)
    awarded_at = Column(DateTime)
    claimed = Column(Boolean, default="false")
    claimed_at = Column(DateTime, nullable=True)
    prize_id = Column(Integer, ForeignKey("tournament_prize.id"), nullable=False)
    prize = relationship("TournamentPrize", foreign_keys=[prize_id])
    player_id = Column(Integer, ForeignKey("player.id"), nullable=False)
    player = relationship("Player", foreign_keys=[player_id])

    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.final_placement is None or self.final_placement > 0)):
            errors.append("Final placement must be greater than zero")
        return errors

    def validate_implies(self) -> list[str]:
        errors = []
        if (self.claimed is True) and not (self.claimed_at is not None):
            errors.append("Claimed prize must have a claimed_at timestamp")
        return errors
    def __repr__(self) -> str:
        return f"<AwardedPrize id={{self.id}}>"
