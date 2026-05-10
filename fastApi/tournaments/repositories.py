"""
Repository layer for the Tournaments BC bounded context.
Abstracts data access from domain logic.
"""

from sqlalchemy.orm import Session

from .models import Season, Tournament, TournamentJudge, TournamentRegistration, TournamentRound, Match, Game, TournamentPrize, AwardedPrize


class SeasonRepository:
    """Repository for Season."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> Season | None:
        return db.query(Season).filter(Season.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[Season]:
        return db.query(Season).all()


class TournamentRepository:
    """Repository for Tournament."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> Tournament | None:
        return db.query(Tournament).filter(Tournament.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[Tournament]:
        return db.query(Tournament).all()


class TournamentJudgeRepository:
    """Repository for TournamentJudge."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> TournamentJudge | None:
        return db.query(TournamentJudge).filter(TournamentJudge.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[TournamentJudge]:
        return db.query(TournamentJudge).all()


class TournamentRegistrationRepository:
    """Repository for TournamentRegistration."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> TournamentRegistration | None:
        return db.query(TournamentRegistration).filter(TournamentRegistration.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[TournamentRegistration]:
        return db.query(TournamentRegistration).all()


class TournamentRoundRepository:
    """Repository for TournamentRound."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> TournamentRound | None:
        return db.query(TournamentRound).filter(TournamentRound.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[TournamentRound]:
        return db.query(TournamentRound).all()


class MatchRepository:
    """Repository for Match."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> Match | None:
        return db.query(Match).filter(Match.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[Match]:
        return db.query(Match).all()


class GameRepository:
    """Repository for Game."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> Game | None:
        return db.query(Game).filter(Game.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[Game]:
        return db.query(Game).all()


class TournamentPrizeRepository:
    """Repository for TournamentPrize."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> TournamentPrize | None:
        return db.query(TournamentPrize).filter(TournamentPrize.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[TournamentPrize]:
        return db.query(TournamentPrize).all()


class AwardedPrizeRepository:
    """Repository for AwardedPrize."""

    @staticmethod
    def get_by_id(db: Session, pk: int) -> AwardedPrize | None:
        return db.query(AwardedPrize).filter(AwardedPrize.id == pk).first()

    @staticmethod
    def find_all(db: Session) -> list[AwardedPrize]:
        return db.query(AwardedPrize).all()
