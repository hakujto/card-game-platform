"""
Domain services for the Tournaments BC bounded context.
Place business logic that does not belong to a single model here.
"""

from sqlalchemy.orm import Session

from .models import Season, Tournament, TournamentJudge, TournamentRegistration, TournamentRound, Match, Game, TournamentPrize, AwardedPrize


class SeasonService:
    """Domain service for Season aggregate."""

    @staticmethod
    def activate(db: Session, pk: int):
        obj = db.query(Season).filter(Season.id == pk).first()
        if obj is None:
            raise ValueError("Season not found: " + str(pk))
        obj.activate()
        db.add(obj)
        db.commit()

    @staticmethod
    def deactivate(db: Session, pk: int):
        obj = db.query(Season).filter(Season.id == pk).first()
        if obj is None:
            raise ValueError("Season not found: " + str(pk))
        obj.deactivate()
        db.add(obj)
        db.commit()

    @staticmethod
    def finalize_rewards(db: Session, pk: int):
        obj = db.query(Season).filter(Season.id == pk).first()
        if obj is None:
            raise ValueError("Season not found: " + str(pk))
        obj.finalize_rewards()
        db.add(obj)
        db.commit()

    @staticmethod
    def is_ongoing(db: Session, pk: int) -> bool:
        obj = db.query(Season).filter(Season.id == pk).first()
        if obj is None:
            raise ValueError("Season not found: " + str(pk))
        result = obj.is_ongoing()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class TournamentService:
    """Domain service for Tournament aggregate."""

    @staticmethod
    def start(db: Session, pk: int):
        obj = db.query(Tournament).filter(Tournament.id == pk).first()
        if obj is None:
            raise ValueError("Tournament not found: " + str(pk))
        obj.start()
        db.add(obj)
        db.commit()

    @staticmethod
    def cancel(db: Session, pk: int):
        obj = db.query(Tournament).filter(Tournament.id == pk).first()
        if obj is None:
            raise ValueError("Tournament not found: " + str(pk))
        obj.cancel()
        db.add(obj)
        db.commit()

    @staticmethod
    def complete(db: Session, pk: int):
        obj = db.query(Tournament).filter(Tournament.id == pk).first()
        if obj is None:
            raise ValueError("Tournament not found: " + str(pk))
        obj.complete()
        db.add(obj)
        db.commit()

    @staticmethod
    def generate_round(db: Session, pk: int):
        obj = db.query(Tournament).filter(Tournament.id == pk).first()
        if obj is None:
            raise ValueError("Tournament not found: " + str(pk))
        obj.generate_round()
        db.add(obj)
        db.commit()

    @staticmethod
    def calculate_prize_distribution(db: Session, pk: int) -> float:
        obj = db.query(Tournament).filter(Tournament.id == pk).first()
        if obj is None:
            raise ValueError("Tournament not found: " + str(pk))
        result = obj.calculate_prize_distribution()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def register_player(db: Session, pk: int, player_id: int, deck_id: int):
        obj = db.query(Tournament).filter(Tournament.id == pk).first()
        if obj is None:
            raise ValueError("Tournament not found: " + str(pk))
        obj.register_player(player_id, deck_id)
        db.add(obj)
        db.commit()

    @staticmethod
    def is_full(db: Session, pk: int) -> bool:
        obj = db.query(Tournament).filter(Tournament.id == pk).first()
        if obj is None:
            raise ValueError("Tournament not found: " + str(pk))
        result = obj.is_full()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class TournamentJudgeService:
    """Domain service for TournamentJudge aggregate."""

    @staticmethod
    def promote_to_head(db: Session, pk: int):
        obj = db.query(TournamentJudge).filter(TournamentJudge.id == pk).first()
        if obj is None:
            raise ValueError("TournamentJudge not found: " + str(pk))
        obj.promote_to_head()
        db.add(obj)
        db.commit()

    @staticmethod
    def remove(db: Session, pk: int):
        obj = db.query(TournamentJudge).filter(TournamentJudge.id == pk).first()
        if obj is None:
            raise ValueError("TournamentJudge not found: " + str(pk))
        obj.remove()
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class TournamentRegistrationService:
    """Domain service for TournamentRegistration aggregate."""

    @staticmethod
    def withdraw(db: Session, pk: int):
        obj = db.query(TournamentRegistration).filter(TournamentRegistration.id == pk).first()
        if obj is None:
            raise ValueError("TournamentRegistration not found: " + str(pk))
        obj.withdraw()
        db.add(obj)
        db.commit()

    @staticmethod
    def disqualify(db: Session, pk: int, reason: str):
        obj = db.query(TournamentRegistration).filter(TournamentRegistration.id == pk).first()
        if obj is None:
            raise ValueError("TournamentRegistration not found: " + str(pk))
        obj.disqualify(reason)
        db.add(obj)
        db.commit()

    @staticmethod
    def promote_from_waitlist(db: Session, pk: int):
        obj = db.query(TournamentRegistration).filter(TournamentRegistration.id == pk).first()
        if obj is None:
            raise ValueError("TournamentRegistration not found: " + str(pk))
        obj.promote_from_waitlist()
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class TournamentRoundService:
    """Domain service for TournamentRound aggregate."""

    @staticmethod
    def start(db: Session, pk: int):
        obj = db.query(TournamentRound).filter(TournamentRound.id == pk).first()
        if obj is None:
            raise ValueError("TournamentRound not found: " + str(pk))
        obj.start()
        db.add(obj)
        db.commit()

    @staticmethod
    def complete(db: Session, pk: int):
        obj = db.query(TournamentRound).filter(TournamentRound.id == pk).first()
        if obj is None:
            raise ValueError("TournamentRound not found: " + str(pk))
        obj.complete()
        db.add(obj)
        db.commit()

    @staticmethod
    def generate_pairings(db: Session, pk: int):
        obj = db.query(TournamentRound).filter(TournamentRound.id == pk).first()
        if obj is None:
            raise ValueError("TournamentRound not found: " + str(pk))
        obj.generate_pairings()
        db.add(obj)
        db.commit()

    @staticmethod
    def is_time_expired(db: Session, pk: int) -> bool:
        obj = db.query(TournamentRound).filter(TournamentRound.id == pk).first()
        if obj is None:
            raise ValueError("TournamentRound not found: " + str(pk))
        result = obj.is_time_expired()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class MatchService:
    """Domain service for Match aggregate."""

    @staticmethod
    def record_result(db: Session, pk: int, p1_wins: int, p2_wins: int):
        obj = db.query(Match).filter(Match.id == pk).first()
        if obj is None:
            raise ValueError("Match not found: " + str(pk))
        obj.record_result(p1_wins, p2_wins)
        obj.determine_winner()  # @after
        db.add(obj)
        db.commit()

    @staticmethod
    def determine_winner(db: Session, pk: int) -> bool:
        obj = db.query(Match).filter(Match.id == pk).first()
        if obj is None:
            raise ValueError("Match not found: " + str(pk))
        result = obj.determine_winner()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def concede(db: Session, pk: int, player_id: int):
        obj = db.query(Match).filter(Match.id == pk).first()
        if obj is None:
            raise ValueError("Match not found: " + str(pk))
        obj.concede(player_id)
        db.add(obj)
        db.commit()

    @staticmethod
    def draw(db: Session, pk: int):
        obj = db.query(Match).filter(Match.id == pk).first()
        if obj is None:
            raise ValueError("Match not found: " + str(pk))
        obj.draw()
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class GameService:
    """Domain service for Game aggregate."""

    @staticmethod
    def record_winner(db: Session, pk: int, winner_side: str):
        obj = db.query(Game).filter(Game.id == pk).first()
        if obj is None:
            raise ValueError("Game not found: " + str(pk))
        obj.record_winner(winner_side)
        db.add(obj)
        db.commit()

    @staticmethod
    def duration_minutes(db: Session, pk: int) -> float:
        obj = db.query(Game).filter(Game.id == pk).first()
        if obj is None:
            raise ValueError("Game not found: " + str(pk))
        result = obj.duration_minutes()
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class TournamentPrizeService:
    """Domain service for TournamentPrize aggregate."""

    @staticmethod
    def applies_to_placement(db: Session, pk: int, placement: int) -> bool:
        obj = db.query(TournamentPrize).filter(TournamentPrize.id == pk).first()
        if obj is None:
            raise ValueError("TournamentPrize not found: " + str(pk))
        result = obj.applies_to_placement(placement)
        db.add(obj)
        db.commit()
        return result

    @staticmethod
    def award_to_player(db: Session, pk: int, player_id: int):
        obj = db.query(TournamentPrize).filter(TournamentPrize.id == pk).first()
        if obj is None:
            raise ValueError("TournamentPrize not found: " + str(pk))
        obj.award_to_player(player_id)
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError


class AwardedPrizeService:
    """Domain service for AwardedPrize aggregate."""

    @staticmethod
    def claim(db: Session, pk: int):
        obj = db.query(AwardedPrize).filter(AwardedPrize.id == pk).first()
        if obj is None:
            raise ValueError("AwardedPrize not found: " + str(pk))
        obj.claim()
        db.add(obj)
        db.commit()

    @staticmethod
    def set_claimed(db: Session, pk: int, value: str) -> None:
        obj = db.query(AwardedPrize).filter(AwardedPrize.id == pk).first()
        if obj is None:
            raise ValueError("AwardedPrize not found: " + str(pk))
        obj.claimed = value
        if value == "TRUE":
            obj.claim()  # @on(claimed = true)
        db.add(obj)
        db.commit()

    @staticmethod
    def create(data: dict) -> None:
        raise NotImplementedError

    @staticmethod
    def update(instance: object, data: dict) -> None:
        raise NotImplementedError
