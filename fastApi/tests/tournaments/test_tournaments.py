import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.db import Base, get_db
from app.main import app


@pytest.fixture
def client():
    # StaticPool keeps a single connection so in-memory DB is shared across threads
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(bind=engine)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

    def override_get_db():
        db = SessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()
    engine.dispose()


class TestSeason:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/seasons")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}
        res = client.post("/api/seasons", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        res = client.get(f"/api/seasons/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        res = client.put(f"/api/seasons/{created['id']}", json={"name": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        res = client.delete(f"/api/seasons/{created['id']}")
        assert res.status_code == 204


class TestTournament:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/tournaments")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        data = {"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}
        res = client.post("/api/tournaments", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        res = client.get(f"/api/tournaments/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        res = client.put(f"/api/tournaments/{created['id']}", json={"name": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        res = client.delete(f"/api/tournaments/{created['id']}")
        assert res.status_code == 204


class TestTournamentJudge:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/tournament_judges")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        data = {"role": "HeadJudge", "tournament_id": _dep_tournament["id"], "player_id": _dep_player["id"]}
        res = client.post("/api/tournament_judges", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_judges", json={"role": "HeadJudge", "tournament_id": _dep_tournament["id"], "player_id": _dep_player["id"]}).json()
        res = client.get(f"/api/tournament_judges/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_judges", json={"role": "HeadJudge", "tournament_id": _dep_tournament["id"], "player_id": _dep_player["id"]}).json()
        res = client.put(f"/api/tournament_judges/{created['id']}", json={})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_judges", json={"role": "HeadJudge", "tournament_id": _dep_tournament["id"], "player_id": _dep_player["id"]}).json()
        res = client.delete(f"/api/tournament_judges/{created['id']}")
        assert res.status_code == 204


class TestTournamentRegistration:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/tournament_registrations")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        data = {"status": "Registered", "points_earned": 0, "registered_at": "2024-01-01T00:00:00", "tournament_id": _dep_tournament["id"], "player_id": _dep_player["id"], "deck_id": _dep_deck["id"]}
        res = client.post("/api/tournament_registrations", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_registrations", json={"status": "Registered", "points_earned": 0, "registered_at": "2024-01-01T00:00:00", "tournament_id": _dep_tournament["id"], "player_id": _dep_player["id"], "deck_id": _dep_deck["id"]}).json()
        res = client.get(f"/api/tournament_registrations/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_registrations", json={"status": "Registered", "points_earned": 0, "registered_at": "2024-01-01T00:00:00", "tournament_id": _dep_tournament["id"], "player_id": _dep_player["id"], "deck_id": _dep_deck["id"]}).json()
        res = client.put(f"/api/tournament_registrations/{created['id']}", json={"seed": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_registrations", json={"status": "Registered", "points_earned": 0, "registered_at": "2024-01-01T00:00:00", "tournament_id": _dep_tournament["id"], "player_id": _dep_player["id"], "deck_id": _dep_deck["id"]}).json()
        res = client.delete(f"/api/tournament_registrations/{created['id']}")
        assert res.status_code == 204


class TestTournamentRound:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/tournament_rounds")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        data = {"round_number": 0, "status": "Pending", "time_limit_minutes": 0, "tournament_id": _dep_tournament["id"]}
        res = client.post("/api/tournament_rounds", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_rounds", json={"round_number": 0, "status": "Pending", "time_limit_minutes": 0, "tournament_id": _dep_tournament["id"]}).json()
        res = client.get(f"/api/tournament_rounds/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_rounds", json={"round_number": 0, "status": "Pending", "time_limit_minutes": 0, "tournament_id": _dep_tournament["id"]}).json()
        res = client.put(f"/api/tournament_rounds/{created['id']}", json={"round_number": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_rounds", json={"round_number": 0, "status": "Pending", "time_limit_minutes": 0, "tournament_id": _dep_tournament["id"]}).json()
        res = client.delete(f"/api/tournament_rounds/{created['id']}")
        assert res.status_code == 204


class TestMatch:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/matches")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        data = {"status": "Pending", "player1_wins": 0, "player2_wins": 0, "player1_id": _dep_player["id"]}
        res = client.post("/api/matches", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "player1_id": _dep_player["id"]}).json()
        res = client.get(f"/api/matches/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "player1_id": _dep_player["id"]}).json()
        res = client.put(f"/api/matches/{created['id']}", json={"table_number": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "player1_id": _dep_player["id"]}).json()
        res = client.delete(f"/api/matches/{created['id']}")
        assert res.status_code == 204


class TestGame:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/games")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_match = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "player1_id": _dep_player["id"]}).json()
        data = {"game_number": 0, "match_id": _dep_match["id"]}
        res = client.post("/api/games", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_match = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "player1_id": _dep_player["id"]}).json()
        created = client.post("/api/games", json={"game_number": 0, "match_id": _dep_match["id"]}).json()
        res = client.get(f"/api/games/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_match = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "player1_id": _dep_player["id"]}).json()
        created = client.post("/api/games", json={"game_number": 0, "match_id": _dep_match["id"]}).json()
        res = client.put(f"/api/games/{created['id']}", json={"game_number": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_match = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "player1_id": _dep_player["id"]}).json()
        created = client.post("/api/games", json={"game_number": 0, "match_id": _dep_match["id"]}).json()
        res = client.delete(f"/api/games/{created['id']}")
        assert res.status_code == 204


class TestTournamentPrize:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/tournament_prizes")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        data = {"placement_from": 0, "placement_to": 0, "prize_type": "Currency", "amount": 0.0, "season_points": 0, "tournament_id": _dep_tournament["id"]}
        res = client.post("/api/tournament_prizes", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_prizes", json={"placement_from": 0, "placement_to": 0, "prize_type": "Currency", "amount": 0.0, "season_points": 0, "tournament_id": _dep_tournament["id"]}).json()
        res = client.get(f"/api/tournament_prizes/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_prizes", json={"placement_from": 0, "placement_to": 0, "prize_type": "Currency", "amount": 0.0, "season_points": 0, "tournament_id": _dep_tournament["id"]}).json()
        res = client.put(f"/api/tournament_prizes/{created['id']}", json={"placement_from": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_prizes", json={"placement_from": 0, "placement_to": 0, "prize_type": "Currency", "amount": 0.0, "season_points": 0, "tournament_id": _dep_tournament["id"]}).json()
        res = client.delete(f"/api/tournament_prizes/{created['id']}")
        assert res.status_code == 204


class TestAwardedPrize:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/awarded_prizes")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        _dep_tournament_prize = client.post("/api/tournament_prizes", json={"placement_from": 0, "placement_to": 0, "prize_type": "Currency", "amount": 0.0, "season_points": 0, "tournament_id": _dep_tournament["id"]}).json()
        data = {"final_placement": 0, "awarded_at": "2024-01-01T00:00:00", "claimed": False, "prize_id": _dep_tournament_prize["id"], "player_id": _dep_player["id"]}
        res = client.post("/api/awarded_prizes", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        _dep_tournament_prize = client.post("/api/tournament_prizes", json={"placement_from": 0, "placement_to": 0, "prize_type": "Currency", "amount": 0.0, "season_points": 0, "tournament_id": _dep_tournament["id"]}).json()
        created = client.post("/api/awarded_prizes", json={"final_placement": 0, "awarded_at": "2024-01-01T00:00:00", "claimed": False, "prize_id": _dep_tournament_prize["id"], "player_id": _dep_player["id"]}).json()
        res = client.get(f"/api/awarded_prizes/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        _dep_tournament_prize = client.post("/api/tournament_prizes", json={"placement_from": 0, "placement_to": 0, "prize_type": "Currency", "amount": 0.0, "season_points": 0, "tournament_id": _dep_tournament["id"]}).json()
        created = client.post("/api/awarded_prizes", json={"final_placement": 0, "awarded_at": "2024-01-01T00:00:00", "claimed": False, "prize_id": _dep_tournament_prize["id"], "player_id": _dep_player["id"]}).json()
        res = client.put(f"/api/awarded_prizes/{created['id']}", json={"final_placement": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "format": "Standard", "tournament_type": "Swiss", "status": "Draft", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        _dep_tournament_prize = client.post("/api/tournament_prizes", json={"placement_from": 0, "placement_to": 0, "prize_type": "Currency", "amount": 0.0, "season_points": 0, "tournament_id": _dep_tournament["id"]}).json()
        created = client.post("/api/awarded_prizes", json={"final_placement": 0, "awarded_at": "2024-01-01T00:00:00", "claimed": False, "prize_id": _dep_tournament_prize["id"], "player_id": _dep_player["id"]}).json()
        res = client.delete(f"/api/awarded_prizes/{created['id']}")
        assert res.status_code == 204
