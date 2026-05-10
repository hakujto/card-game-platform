from datetime import date, datetime

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.db import Base, get_db
from app.main import app

SQLALCHEMY_TEST_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_TEST_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(autouse=True)
def setup_db():
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


@pytest.fixture
def client():
    def override_get_db():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()
    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()


class TestSeason:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/seasons")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"name": "test", "start_date": date(2024, 1, 1), "end_date": date(2024, 1, 1), "format": "test", "is_active": False}
        res = client.post("/api/seasons", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/seasons", json={"name": "test", "start_date": date(2024, 1, 1), "end_date": date(2024, 1, 1), "format": "test", "is_active": False}).json()
        res = client.get(f"/api/seasons/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/seasons", json={"name": "test", "start_date": date(2024, 1, 1), "end_date": date(2024, 1, 1), "format": "test", "is_active": False}).json()
        res = client.put(f"/api/seasons/{created['id']}", json={"name": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/seasons", json={"name": "test", "start_date": date(2024, 1, 1), "end_date": date(2024, 1, 1), "format": "test", "is_active": False}).json()
        res = client.delete(f"/api/seasons/{created['id']}")
        assert res.status_code == 204


class TestTournament:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/tournaments")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"name": "test", "format": "test", "tournament_type": "test", "status": "test", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": datetime(2024, 1, 1, 0, 0, 0), "is_online": False, "created_at": datetime(2024, 1, 1, 0, 0, 0)}
        res = client.post("/api/tournaments", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/tournaments", json={"name": "test", "format": "test", "tournament_type": "test", "status": "test", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": datetime(2024, 1, 1, 0, 0, 0), "is_online": False, "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.get(f"/api/tournaments/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/tournaments", json={"name": "test", "format": "test", "tournament_type": "test", "status": "test", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": datetime(2024, 1, 1, 0, 0, 0), "is_online": False, "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.put(f"/api/tournaments/{created['id']}", json={"name": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/tournaments", json={"name": "test", "format": "test", "tournament_type": "test", "status": "test", "max_players": 0, "entry_fee": 0.0, "prize_pool": 0.0, "start_time": datetime(2024, 1, 1, 0, 0, 0), "is_online": False, "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.delete(f"/api/tournaments/{created['id']}")
        assert res.status_code == 204


class TestTournamentJudge:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/tournament_judges")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"role": "test"}
        res = client.post("/api/tournament_judges", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/tournament_judges", json={"role": "test"}).json()
        res = client.get(f"/api/tournament_judges/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/tournament_judges", json={"role": "test"}).json()
        res = client.put(f"/api/tournament_judges/{created['id']}", json={"role": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/tournament_judges", json={"role": "test"}).json()
        res = client.delete(f"/api/tournament_judges/{created['id']}")
        assert res.status_code == 204


class TestTournamentRegistration:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/tournament_registrations")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"status": "test", "points_earned": 0, "registered_at": datetime(2024, 1, 1, 0, 0, 0)}
        res = client.post("/api/tournament_registrations", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/tournament_registrations", json={"status": "test", "points_earned": 0, "registered_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.get(f"/api/tournament_registrations/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/tournament_registrations", json={"status": "test", "points_earned": 0, "registered_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.put(f"/api/tournament_registrations/{created['id']}", json={"status": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/tournament_registrations", json={"status": "test", "points_earned": 0, "registered_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.delete(f"/api/tournament_registrations/{created['id']}")
        assert res.status_code == 204


class TestTournamentRound:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/tournament_rounds")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"round_number": 0, "status": "test", "time_limit_minutes": 0}
        res = client.post("/api/tournament_rounds", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/tournament_rounds", json={"round_number": 0, "status": "test", "time_limit_minutes": 0}).json()
        res = client.get(f"/api/tournament_rounds/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/tournament_rounds", json={"round_number": 0, "status": "test", "time_limit_minutes": 0}).json()
        res = client.put(f"/api/tournament_rounds/{created['id']}", json={"round_number": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/tournament_rounds", json={"round_number": 0, "status": "test", "time_limit_minutes": 0}).json()
        res = client.delete(f"/api/tournament_rounds/{created['id']}")
        assert res.status_code == 204


class TestMatch:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/matches")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"status": "test", "player1_wins": 0, "player2_wins": 0}
        res = client.post("/api/matches", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/matches", json={"status": "test", "player1_wins": 0, "player2_wins": 0}).json()
        res = client.get(f"/api/matches/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/matches", json={"status": "test", "player1_wins": 0, "player2_wins": 0}).json()
        res = client.put(f"/api/matches/{created['id']}", json={"table_number": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/matches", json={"status": "test", "player1_wins": 0, "player2_wins": 0}).json()
        res = client.delete(f"/api/matches/{created['id']}")
        assert res.status_code == 204


class TestGame:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/games")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"game_number": 0}
        res = client.post("/api/games", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/games", json={"game_number": 0}).json()
        res = client.get(f"/api/games/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/games", json={"game_number": 0}).json()
        res = client.put(f"/api/games/{created['id']}", json={"game_number": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/games", json={"game_number": 0}).json()
        res = client.delete(f"/api/games/{created['id']}")
        assert res.status_code == 204


class TestTournamentPrize:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/tournament_prizes")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"placement_from": 0, "placement_to": 0, "prize_type": "test", "amount": 0.0, "season_points": 0}
        res = client.post("/api/tournament_prizes", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/tournament_prizes", json={"placement_from": 0, "placement_to": 0, "prize_type": "test", "amount": 0.0, "season_points": 0}).json()
        res = client.get(f"/api/tournament_prizes/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/tournament_prizes", json={"placement_from": 0, "placement_to": 0, "prize_type": "test", "amount": 0.0, "season_points": 0}).json()
        res = client.put(f"/api/tournament_prizes/{created['id']}", json={"placement_from": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/tournament_prizes", json={"placement_from": 0, "placement_to": 0, "prize_type": "test", "amount": 0.0, "season_points": 0}).json()
        res = client.delete(f"/api/tournament_prizes/{created['id']}")
        assert res.status_code == 204


class TestAwardedPrize:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/awarded_prizes")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"final_placement": 0, "awarded_at": datetime(2024, 1, 1, 0, 0, 0), "claimed": False}
        res = client.post("/api/awarded_prizes", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/awarded_prizes", json={"final_placement": 0, "awarded_at": datetime(2024, 1, 1, 0, 0, 0), "claimed": False}).json()
        res = client.get(f"/api/awarded_prizes/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/awarded_prizes", json={"final_placement": 0, "awarded_at": datetime(2024, 1, 1, 0, 0, 0), "claimed": False}).json()
        res = client.put(f"/api/awarded_prizes/{created['id']}", json={"final_placement": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/awarded_prizes", json={"final_placement": 0, "awarded_at": datetime(2024, 1, 1, 0, 0, 0), "claimed": False}).json()
        res = client.delete(f"/api/awarded_prizes/{created['id']}")
        assert res.status_code == 204
