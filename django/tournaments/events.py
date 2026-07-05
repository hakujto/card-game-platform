"""
Domain events for the Tournaments BC bounded context.
Emitted by aggregate behaviors via @emits — see services.py for dispatch stubs.
"""
from dataclasses import dataclass
from datetime import date, datetime
from decimal import Decimal
from typing import Optional
from uuid import UUID


@dataclass
class TournamentCompleted:
    tournament_id: int
    season_id: int
    completed_at: datetime


@dataclass
class PlayerRegistered:
    tournament_id: int
    player_id: int
    registered_at: datetime
