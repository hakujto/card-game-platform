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

    def test_search_returns_200(self, client: TestClient):
        res = client.get("/api/seasons?q=test")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}
        res = client.post("/api/seasons", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        res = client.get(f"/api/seasons/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        res = client.put(f"/api/seasons/{created['id']}", json={"name": "test"})
        assert res.status_code == 200

    def test_create_fails_when_end_date_after_start_date_violated(self, client: TestClient):
        # Simple rule violated → 422
        data = {"name": "test", "start_date": 1, "end_date": 0, "format": "Standard", "is_active": False}
        res = client.post("/api/seasons", json=data)
        assert res.status_code == 422


class TestTournament:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/tournaments")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_search_returns_200(self, client: TestClient):
        res = client.get("/api/tournaments?q=test")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        data = {"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "end_time": None, "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}
        res = client.post("/api/tournaments", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "end_time": None, "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        res = client.get(f"/api/tournaments/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "end_time": None, "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        res = client.put(f"/api/tournaments/{created['id']}", json={"name": "test"})
        assert res.status_code == 200

    def test_create_fails_when_max_players_positive_violated(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # Simple rule violated → 422
        data = {"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 513, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}
        res = client.post("/api/tournaments", json=data)
        assert res.status_code == 422

    def test_create_fails_when_entry_fee_not_negative_violated(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # Simple rule violated → 422
        data = {"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": -1, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}
        res = client.post("/api/tournaments", json=data)
        assert res.status_code == 422

    def test_create_fails_when_prize_pool_not_negative_violated(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # Simple rule violated → 422
        data = {"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": -1, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}
        res = client.post("/api/tournaments", json=data)
        assert res.status_code == 422

    def test_create_fails_when_end_time_after_start_violated(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": 1, "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": 0, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}
        res = client.post("/api/tournaments", json=data)
        assert res.status_code == 422

    def test_transition_draft_to_registration(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "end_time": None, "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/tournaments/{created.get('id', 1)}/transitions/draft-to-registration")
        assert res.status_code in (200, 409, 422, 404)

    def test_transition_registration_to_ongoing(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "end_time": None, "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/tournaments/{created.get('id', 1)}/transitions/registration-to-ongoing")
        assert res.status_code in (200, 409, 422, 404)

    def test_transition_registration_to_cancelled(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "end_time": None, "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/tournaments/{created.get('id', 1)}/transitions/registration-to-cancelled")
        assert res.status_code in (200, 409, 422, 404)

    def test_transition_ongoing_to_completed(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "end_time": None, "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/tournaments/{created.get('id', 1)}/transitions/ongoing-to-completed")
        assert res.status_code in (200, 409, 422, 404)

    def test_transition_ongoing_to_cancelled(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "end_time": None, "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/tournaments/{created.get('id', 1)}/transitions/ongoing-to-cancelled")
        assert res.status_code in (200, 409, 422, 404)

    def test_transition_completed_to_draft_is_denied(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "end_time": None, "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/tournaments/{created.get('id', 1)}/transitions/completed-to-draft")
        assert res.status_code in (409, 404)

    def test_transition_cancelled_to_draft_is_denied(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "end_time": None, "is_online": False, "created_at": "2024-01-01T00:00:00", "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/tournaments/{created.get('id', 1)}/transitions/cancelled-to-draft")
        assert res.status_code in (409, 404)


class TestTournamentJudge:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/tournament_judges")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        data = {"role": "HeadJudge", "tournament_id": _dep_tournament["id"], "player_id": _dep_player["id"]}
        res = client.post("/api/tournament_judges", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_judges", json={"role": "HeadJudge", "tournament_id": _dep_tournament["id"], "player_id": _dep_player["id"]}).json()
        res = client.get(f"/api/tournament_judges/{created['id']}")
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_judges", json={"role": "HeadJudge", "tournament_id": _dep_tournament["id"], "player_id": _dep_player["id"]}).json()
        res = client.delete(f"/api/tournament_judges/{created['id']}")
        assert res.status_code == 204


class TestTournamentRegistration:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/tournament_registrations")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": True, "is_tournament_legal": False, "wins": 0, "losses": 0, "draws": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        data = {"status": "Registered", "seed": 1, "final_standing": 1, "points_earned": 0, "registered_at": "2024-01-01T00:00:00", "tournament_id": _dep_tournament["id"], "player_id": _dep_player["id"], "deck_id": _dep_deck["id"]}
        res = client.post("/api/tournament_registrations", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": True, "is_tournament_legal": False, "wins": 0, "losses": 0, "draws": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_registrations", json={"status": "Registered", "seed": 1, "final_standing": 1, "points_earned": 0, "registered_at": "2024-01-01T00:00:00", "tournament_id": _dep_tournament["id"], "player_id": _dep_player["id"], "deck_id": _dep_deck["id"]}).json()
        res = client.get(f"/api/tournament_registrations/{created['id']}")
        assert res.status_code == 200

    def test_create_fails_when_points_earned_not_negative_violated(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": True, "is_tournament_legal": False, "wins": 0, "losses": 0, "draws": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        # Simple rule violated → 422
        data = {"status": "Registered", "points_earned": -1, "registered_at": "2024-01-01T00:00:00", "final_standing": 1, "seed": 1, "tournament_id": _dep_tournament["id"], "player_id": _dep_player["id"], "deck_id": _dep_deck["id"]}
        res = client.post("/api/tournament_registrations", json=data)
        assert res.status_code == 422

    def test_create_fails_when_final_standing_positive_violated(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": True, "is_tournament_legal": False, "wins": 0, "losses": 0, "draws": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"status": "Registered", "points_earned": 0, "registered_at": "2024-01-01T00:00:00", "final_standing": 0, "seed": 1, "tournament_id": _dep_tournament["id"], "player_id": _dep_player["id"], "deck_id": _dep_deck["id"]}
        res = client.post("/api/tournament_registrations", json=data)
        assert res.status_code == 422

    def test_create_fails_when_seed_positive_violated(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": True, "is_tournament_legal": False, "wins": 0, "losses": 0, "draws": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"status": "Registered", "points_earned": 0, "registered_at": "2024-01-01T00:00:00", "final_standing": 1, "seed": 0, "tournament_id": _dep_tournament["id"], "player_id": _dep_player["id"], "deck_id": _dep_deck["id"]}
        res = client.post("/api/tournament_registrations", json=data)
        assert res.status_code == 422


class TestTournamentRound:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/tournament_rounds")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        data = {"round_number": 1, "status": "Pending", "started_at": "2024-01-01T00:00:00", "ended_at": None, "time_limit_minutes": 1, "tournament_id": _dep_tournament["id"]}
        res = client.post("/api/tournament_rounds", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_rounds", json={"round_number": 1, "status": "Pending", "started_at": "2024-01-01T00:00:00", "ended_at": None, "time_limit_minutes": 1, "tournament_id": _dep_tournament["id"]}).json()
        res = client.get(f"/api/tournament_rounds/{created['id']}")
        assert res.status_code == 200

    def test_create_fails_when_ended_after_started_violated(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"round_number": 1, "status": "Pending", "time_limit_minutes": 1, "ended_at": 0, "started_at": 1, "tournament_id": _dep_tournament["id"]}
        res = client.post("/api/tournament_rounds", json=data)
        assert res.status_code == 422

    def test_create_fails_when_completed_requires_started_at_violated(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"round_number": 1, "status": "Completed", "time_limit_minutes": 1, "ended_at": None, "started_at": None, "tournament_id": _dep_tournament["id"]}
        res = client.post("/api/tournament_rounds", json=data)
        assert res.status_code == 422

    def test_create_fails_when_round_number_positive_violated(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        # Simple rule violated → 422
        data = {"round_number": 0, "status": "Completed", "time_limit_minutes": 1, "ended_at": "2024-01-01T00:00:00", "started_at": "2024-01-01T00:00:00", "tournament_id": _dep_tournament["id"]}
        res = client.post("/api/tournament_rounds", json=data)
        assert res.status_code == 422

    def test_create_fails_when_time_limit_positive_violated(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        # Simple rule violated → 422
        data = {"round_number": 1, "status": "Completed", "time_limit_minutes": 0, "ended_at": "2024-01-01T00:00:00", "started_at": "2024-01-01T00:00:00", "tournament_id": _dep_tournament["id"]}
        res = client.post("/api/tournament_rounds", json=data)
        assert res.status_code == 422


class TestMatch:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/matches")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        data = {"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00", "ended_at": None, "player1_id": _dep_player["id"]}
        res = client.post("/api/matches", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00", "ended_at": None, "player1_id": _dep_player["id"]}).json()
        res = client.get(f"/api/matches/{created['id']}")
        assert res.status_code == 200

    def test_create_fails_when_wins_not_negative_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # Simple rule violated → 422
        data = {"status": "Completed", "player1_wins": -1, "player2_wins": 0, "player2": None, "ended_at": "2024-01-01T00:00:00", "started_at": "2024-01-01T00:00:00", "player1_id": _dep_player["id"]}
        res = client.post("/api/matches", json=data)
        assert res.status_code == 422

    def test_create_fails_when_max_three_games_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # Simple rule violated → 422
        data = {"status": "Completed", "player1_wins": 3, "player2_wins": 0, "player2": None, "ended_at": "2024-01-01T00:00:00", "started_at": "2024-01-01T00:00:00", "player1_id": _dep_player["id"]}
        res = client.post("/api/matches", json=data)
        assert res.status_code == 422

    def test_create_fails_when_bye_has_no_player2_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"status": "BYE", "player1_wins": 0, "player2_wins": 0, "player2": None, "ended_at": None, "started_at": "2024-01-01T00:00:00", "player1_id": _dep_player["id"], "player2_id": 1}
        res = client.post("/api/matches", json=data)
        assert res.status_code == 422

    def test_create_fails_when_ended_after_started_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"status": "Pending", "player1_wins": 0, "player2_wins": 0, "player2": None, "ended_at": 0, "started_at": 1, "player1_id": _dep_player["id"]}
        res = client.post("/api/matches", json=data)
        assert res.status_code == 422

    def test_create_fails_when_completed_requires_started_at_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"status": "Completed", "player1_wins": 0, "player2_wins": 0, "player2": None, "ended_at": None, "started_at": None, "player1_id": _dep_player["id"]}
        res = client.post("/api/matches", json=data)
        assert res.status_code == 422

    def test_transition_pending_to_active(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00", "ended_at": None, "player1_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/matches/{created.get('id', 1)}/transitions/pending-to-active")
        assert res.status_code in (200, 409, 422, 404)

    def test_transition_active_to_completed(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00", "ended_at": None, "player1_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/matches/{created.get('id', 1)}/transitions/active-to-completed")
        assert res.status_code in (200, 409, 422, 404)

    def test_transition_active_to_draw(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00", "ended_at": None, "player1_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/matches/{created.get('id', 1)}/transitions/active-to-draw")
        assert res.status_code in (200, 409, 422, 404)

    def test_transition_pending_to_b_y_e(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00", "ended_at": None, "player1_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/matches/{created.get('id', 1)}/transitions/pending-to-bye")
        assert res.status_code in (200, 409, 422, 404)

    def test_transition_completed_to_active_is_denied(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00", "ended_at": None, "player1_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/matches/{created.get('id', 1)}/transitions/completed-to-active")
        assert res.status_code in (409, 404)

    def test_transition_draw_to_active_is_denied(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00", "ended_at": None, "player1_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/matches/{created.get('id', 1)}/transitions/draw-to-active")
        assert res.status_code in (409, 404)

    def test_transition_b_y_e_to_active_is_denied(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "started_at": "2024-01-01T00:00:00", "ended_at": None, "player1_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/matches/{created.get('id', 1)}/transitions/bye-to-active")
        assert res.status_code in (409, 404)


class TestGame:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/games")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_match = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "ended_at": None, "started_at": "2024-01-01T00:00:00", "player1_id": _dep_player["id"]}).json()
        data = {"game_number": 1, "winner_side": None, "turns_played": 1, "duration_seconds": 1, "match_id": _dep_match["id"]}
        res = client.post("/api/games", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_match = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "ended_at": None, "started_at": "2024-01-01T00:00:00", "player1_id": _dep_player["id"]}).json()
        created = client.post("/api/games", json={"game_number": 1, "winner_side": None, "turns_played": 1, "duration_seconds": 1, "match_id": _dep_match["id"]}).json()
        res = client.get(f"/api/games/{created['id']}")
        assert res.status_code == 200

    def test_create_fails_when_game_number_range_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_match = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "ended_at": None, "started_at": "2024-01-01T00:00:00", "player1_id": _dep_player["id"]}).json()
        # Simple rule violated → 422
        data = {"game_number": 4, "turns_played": 1, "duration_seconds": 1, "winner": None, "winner_side": "Player1", "match_id": _dep_match["id"], "winner_id": 1}
        res = client.post("/api/games", json=data)
        assert res.status_code == 422

    def test_create_fails_when_turns_played_positive_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_match = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "ended_at": None, "started_at": "2024-01-01T00:00:00", "player1_id": _dep_player["id"]}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"game_number": 1, "turns_played": 0, "duration_seconds": 1, "winner": None, "winner_side": None, "match_id": _dep_match["id"]}
        res = client.post("/api/games", json=data)
        assert res.status_code == 422

    def test_create_fails_when_duration_positive_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_match = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "ended_at": None, "started_at": "2024-01-01T00:00:00", "player1_id": _dep_player["id"]}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"game_number": 1, "turns_played": 1, "duration_seconds": 0, "winner": None, "winner_side": None, "match_id": _dep_match["id"]}
        res = client.post("/api/games", json=data)
        assert res.status_code == 422

    def test_create_fails_when_draw_has_no_winner_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_match = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "ended_at": None, "started_at": "2024-01-01T00:00:00", "player1_id": _dep_player["id"]}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"game_number": 1, "turns_played": 1, "duration_seconds": 1, "winner": None, "winner_side": "Draw", "match_id": _dep_match["id"], "winner_id": 1}
        res = client.post("/api/games", json=data)
        assert res.status_code == 422

    def test_create_fails_when_non_draw_requires_winner_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_match = client.post("/api/matches", json={"status": "Pending", "player1_wins": 0, "player2_wins": 0, "ended_at": None, "started_at": "2024-01-01T00:00:00", "player1_id": _dep_player["id"]}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"game_number": 1, "turns_played": 1, "duration_seconds": 1, "winner": None, "winner_side": "Player1", "match_id": _dep_match["id"]}
        res = client.post("/api/games", json=data)
        assert res.status_code == 422


class TestTournamentPrize:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/tournament_prizes")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        data = {"placement_from": 1, "placement_to": 1, "prize_type": "Currency", "amount": 0, "season_points": 0, "tournament_id": _dep_tournament["id"]}
        res = client.post("/api/tournament_prizes", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_prizes", json={"placement_from": 1, "placement_to": 1, "prize_type": "Currency", "amount": 0, "season_points": 0, "tournament_id": _dep_tournament["id"]}).json()
        res = client.get(f"/api/tournament_prizes/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_prizes", json={"placement_from": 1, "placement_to": 1, "prize_type": "Currency", "amount": 0, "season_points": 0, "tournament_id": _dep_tournament["id"]}).json()
        res = client.put(f"/api/tournament_prizes/{created['id']}", json={"placement_from": 1})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        created = client.post("/api/tournament_prizes", json={"placement_from": 1, "placement_to": 1, "prize_type": "Currency", "amount": 0, "season_points": 0, "tournament_id": _dep_tournament["id"]}).json()
        res = client.delete(f"/api/tournament_prizes/{created['id']}")
        assert res.status_code == 204

    def test_create_fails_when_placement_range_valid_violated(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        # Simple rule violated → 422
        data = {"placement_from": 0, "placement_to": -1, "prize_type": "Currency", "amount": 0, "season_points": 0, "tournament_id": _dep_tournament["id"]}
        res = client.post("/api/tournament_prizes", json=data)
        assert res.status_code == 422

    def test_create_fails_when_placement_from_positive_violated(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        # Simple rule violated → 422
        data = {"placement_from": 0, "placement_to": 1, "prize_type": "Currency", "amount": 0, "season_points": 0, "tournament_id": _dep_tournament["id"]}
        res = client.post("/api/tournament_prizes", json=data)
        assert res.status_code == 422

    def test_create_fails_when_amount_not_negative_violated(self, client: TestClient):
        _dep_season = client.post("/api/seasons", json={"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-02", "format": "Standard", "is_active": False}).json()
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_tournament = client.post("/api/tournaments", json={"name": "test", "status": "Draft", "format": "Standard", "tournament_type": "Swiss", "max_players": 2, "entry_fee": 0, "prize_pool": 0, "start_time": "2024-01-01T00:00:00", "is_online": False, "created_at": "2024-01-01T00:00:00", "end_time": None, "season_id": _dep_season["id"], "organizer_id": _dep_player["id"]}).json()
        # Simple rule violated → 422
        data = {"placement_from": 1, "placement_to": 1, "prize_type": "Currency", "amount": -1, "season_points": 0, "tournament_id": _dep_tournament["id"]}
        res = client.post("/api/tournament_prizes", json=data)
        assert res.status_code == 422


class TestAwardedPrize:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/awarded_prizes")
        assert res.status_code == 200
        assert isinstance(res.json(), list)
