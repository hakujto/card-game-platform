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
        # TODO: implement activate
        pass

    def deactivate(self):
        # TODO: implement deactivate
        pass

    def finalize_rewards(self):
        # TODO: implement finalize_rewards
        pass

    def is_ongoing(self) -> bool:
        # TODO: implement is_ongoing
        return None  # type: ignore


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.end_date is None or (self.start_date is not None and self.end_date > self.start_date))):
            errors.append("Season end date must be after start date")
        return errors
    def __repr__(self) -> str:
        return f"<Season id={{self.id}}>"


from typing import Literal

TournamentStatusType = Literal["Draft", "Registration", "Ongoing", "Completed", "Cancelled"]
TournamentFormatType = Literal["Standard", "Extended", "Legacy", "Vintage", "Commander", "Draft"]
TournamentTournamentTypeType = Literal["Swiss", "SingleElimination", "DoubleElimination", "RoundRobin"]

class Tournament(Base):
    __tablename__ = "tournament"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200))
    description = Column(Text, nullable=True)
    status = Column(String(20), default="Draft")
    format = Column(String(20), default="Standard")
    tournament_type = Column(String(20), default="Swiss")
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
        # TODO: implement start
        pass

    def cancel(self):
        # TODO: implement cancel
        pass

    def complete(self):
        # TODO: implement complete
        pass

    def generate_round(self):
        # TODO: implement generate_round
        pass

    def calculate_prize_distribution(self) -> float:
        # TODO: implement calculate_prize_distribution
        return None  # type: ignore

    def register_player(self, player_id: int, deck_id: int):
        # TODO: implement register_player
        pass

    def is_full(self) -> bool:
        # TODO: implement is_full
        return None  # type: ignore


    # ── Lifecycle state machine ──────────────────────────────────────
    ALLOWED_TRANSITIONS: dict = {
        "Draft": ["Registration"],
        "Registration": ["Ongoing", "Cancelled"],
        "Ongoing": ["Completed", "Cancelled"]
    }

    def assert_transition(self, to: str) -> None:
        allowed = self.ALLOWED_TRANSITIONS.get(self.status, [])
        if to not in allowed:
            raise ValueError(f"Transition {self.status} -> {to} not allowed")


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
    # ── Lifecycle hooks ──────────────────────────────────────────────
    def _hook_sync_season_stats(self) -> None:
        # TODO: implement sync_season_stats
        pass

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

    def promote_to_head(self):
        # TODO: implement promote_to_head
        pass

    def remove(self):
        # TODO: implement remove
        pass

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
        # TODO: implement withdraw
        pass

    def disqualify(self, reason: str):
        # TODO: implement disqualify
        pass

    def promote_from_waitlist(self):
        # TODO: implement promote_from_waitlist
        pass


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.points_earned is None or self.points_earned >= 0)):
            errors.append("Points earned must not be negative")
        return errors

    def validate_implies(self) -> list[str]:
        errors = []
        if (self.final_standing is not None) and not ((self.final_standing is None or self.final_standing > 0)):
            errors.append("Final standing must be greater than zero")
        if (self.seed is not None) and not ((self.seed is None or self.seed > 0)):
            errors.append("Seed must be greater than zero")
        return errors
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
        # TODO: implement start
        pass

    def complete(self):
        # TODO: implement complete
        pass

    def generate_pairings(self):
        # TODO: implement generate_pairings
        pass

    def is_time_expired(self) -> bool:
        # TODO: implement is_time_expired
        return None  # type: ignore


    def validate_rules(self) -> list[str]:
        errors = []
        if not ((self.round_number is None or self.round_number > 0)):
            errors.append("Round number must be greater than zero")
        if not ((self.time_limit_minutes is None or self.time_limit_minutes > 0)):
            errors.append("Round time limit must be greater than zero")
        return errors

    def validate_implies(self) -> list[str]:
        errors = []
        if (self.ended_at is not None) and not ((self.ended_at is None or (self.started_at is not None and self.ended_at > self.started_at))):
            errors.append("Round end time must be after start time")
        if (self.status == "Completed") and not (self.started_at is not None):
            errors.append("Completed round must have a start time")
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
        # TODO: implement record_result
        pass

    def finalize_result(self):
        # TODO: implement finalize_result
        pass

    def determine_winner(self) -> bool:
        # TODO: implement determine_winner
        return None  # type: ignore

    def concede(self, player_id: int):
        # TODO: implement concede
        pass

    def draw(self):
        # TODO: implement draw
        pass


    # ── Lifecycle state machine ──────────────────────────────────────
    ALLOWED_TRANSITIONS: dict = {
        "Pending": ["Active", "BYE"],
        "Active": ["Completed", "Draw"]
    }

    def assert_transition(self, to: str) -> None:
        allowed = self.ALLOWED_TRANSITIONS.get(self.status, [])
        if to not in allowed:
            raise ValueError(f"Transition {self.status} -> {to} not allowed")


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
        if (self.ended_at is not None) and not ((self.ended_at is None or (self.started_at is not None and self.ended_at > self.started_at))):
            errors.append("Match end time must be after start time")
        if (self.status == "Completed") and not (self.started_at is not None):
            errors.append("Completed match must have a start time")
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
        # TODO: implement record_winner
        pass

    def duration_minutes(self) -> float:
        # TODO: implement duration_minutes
        return None  # type: ignore


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
        if (self.winner_side == "Draw") and not (self.winner_id is None):
            errors.append("A draw cannot have a winner")
        if ((self.winner_side is not None and self.winner_side != "Draw")) and not (self.winner_id is not None):
            errors.append("A decisive game must have a winner player set")
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
        # TODO: implement applies_to_placement
        return None  # type: ignore

    def award_to_player(self, player_id: int):
        # TODO: implement award_to_player
        pass


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

    def claim(self):
        # TODO: implement claim
        pass


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



# ── SQLAlchemy event listeners ───────────────────────────────────────────
from sqlalchemy import event

@event.listens_for(Tournament, "after_update")
def _tournament_sync_season_stats(mapper, connection, target):
    target._hook_sync_season_stats()
