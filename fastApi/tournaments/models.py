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
    registrations_id = Column(Integer, ForeignKey("tournament_registration.id"), nullable=True)
    registrations = relationship("TournamentRegistration", foreign_keys=[registrations_id])
    rounds_id = Column(Integer, ForeignKey("tournament_round.id"), nullable=True)
    rounds = relationship("TournamentRound", foreign_keys=[rounds_id])
    prizes_id = Column(Integer, ForeignKey("tournament_prize.id"), nullable=True)
    prizes = relationship("TournamentPrize", foreign_keys=[prizes_id])
    judges = relationship("Player", secondary=tournament_judges_assoc)

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
    matches_id = Column(Integer, ForeignKey("match.id"), nullable=False)
    matches = relationship("Match", foreign_keys=[matches_id])

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
    games_id = Column(Integer, ForeignKey("game.id"), nullable=True)
    games = relationship("Game", foreign_keys=[games_id])

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

    def __repr__(self) -> str:
        return f"<AwardedPrize id={{self.id}}>"
