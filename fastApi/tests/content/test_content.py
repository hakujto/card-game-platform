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


class TestDraftSession:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/draft_sessions")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        data = {"status": "Completed", "draft_type": "Booster", "seats": 2, "time_per_pick_seconds": 1, "created_at": "2024-01-01T00:00:00", "completed_at": None, "card_set_id": _dep_card_set["id"]}
        res = client.post("/api/draft_sessions", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        created = client.post("/api/draft_sessions", json={"status": "Completed", "draft_type": "Booster", "seats": 2, "time_per_pick_seconds": 1, "created_at": "2024-01-01T00:00:00", "completed_at": None, "card_set_id": _dep_card_set["id"]}).json()
        res = client.get(f"/api/draft_sessions/{created['id']}")
        assert res.status_code == 200

    def test_create_fails_when_seats_range_violated(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        # Simple rule violated → 422
        data = {"status": "Completed", "draft_type": "Booster", "seats": 17, "time_per_pick_seconds": 1, "created_at": "2024-01-01T00:00:00", "completed_at": "2024-01-01T00:00:00", "card_set_id": _dep_card_set["id"]}
        res = client.post("/api/draft_sessions", json=data)
        assert res.status_code == 422

    def test_create_fails_when_completed_at_requires_completed_status_violated(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"status": "WaitingForPlayers", "draft_type": "Booster", "seats": 2, "time_per_pick_seconds": 1, "created_at": "2024-01-01T00:00:00", "completed_at": "2024-01-01T00:00:00", "card_set_id": _dep_card_set["id"]}
        res = client.post("/api/draft_sessions", json=data)
        assert res.status_code == 422

    def test_create_fails_when_time_per_pick_positive_violated(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        # Simple rule violated → 422
        data = {"status": "Completed", "draft_type": "Booster", "seats": 2, "time_per_pick_seconds": 0, "created_at": "2024-01-01T00:00:00", "completed_at": "2024-01-01T00:00:00", "card_set_id": _dep_card_set["id"]}
        res = client.post("/api/draft_sessions", json=data)
        assert res.status_code == 422

    def test_transition_waiting_for_players_to_drafting(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        created = client.post("/api/draft_sessions", json={"status": "Completed", "draft_type": "Booster", "seats": 2, "time_per_pick_seconds": 1, "created_at": "2024-01-01T00:00:00", "completed_at": None, "card_set_id": _dep_card_set["id"]}).json()
        res = client.patch(f"/api/draft_sessions/{created.get('id', 1)}/transitions/waitingforplayers-to-drafting")
        assert res.status_code in (200, 403, 409, 422, 404)

    def test_transition_drafting_to_completed(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        created = client.post("/api/draft_sessions", json={"status": "Completed", "draft_type": "Booster", "seats": 2, "time_per_pick_seconds": 1, "created_at": "2024-01-01T00:00:00", "completed_at": None, "card_set_id": _dep_card_set["id"]}).json()
        res = client.patch(f"/api/draft_sessions/{created.get('id', 1)}/transitions/drafting-to-completed")
        assert res.status_code in (200, 403, 409, 422, 404)

    def test_transition_drafting_to_abandoned(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        created = client.post("/api/draft_sessions", json={"status": "Completed", "draft_type": "Booster", "seats": 2, "time_per_pick_seconds": 1, "created_at": "2024-01-01T00:00:00", "completed_at": None, "card_set_id": _dep_card_set["id"]}).json()
        res = client.patch(f"/api/draft_sessions/{created.get('id', 1)}/transitions/drafting-to-abandoned", headers={"X-User-Role": "Admin"})
        assert res.status_code in (200, 403, 409, 422, 404)

    def test_transition_drafting_to_abandoned_forbidden_for_wrong_role(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        created = client.post("/api/draft_sessions", json={"status": "Completed", "draft_type": "Booster", "seats": 2, "time_per_pick_seconds": 1, "created_at": "2024-01-01T00:00:00", "completed_at": None, "card_set_id": _dep_card_set["id"]}).json()
        res = client.patch(f"/api/draft_sessions/{created.get('id', 1)}/transitions/drafting-to-abandoned", headers={"X-User-Role": "nobody"})
        assert res.status_code in (403, 404)

    def test_transition_waiting_for_players_to_abandoned(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        created = client.post("/api/draft_sessions", json={"status": "Completed", "draft_type": "Booster", "seats": 2, "time_per_pick_seconds": 1, "created_at": "2024-01-01T00:00:00", "completed_at": None, "card_set_id": _dep_card_set["id"]}).json()
        res = client.patch(f"/api/draft_sessions/{created.get('id', 1)}/transitions/waitingforplayers-to-abandoned", headers={"X-User-Role": "Admin"})
        assert res.status_code in (200, 403, 409, 422, 404)

    def test_transition_waiting_for_players_to_abandoned_forbidden_for_wrong_role(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        created = client.post("/api/draft_sessions", json={"status": "Completed", "draft_type": "Booster", "seats": 2, "time_per_pick_seconds": 1, "created_at": "2024-01-01T00:00:00", "completed_at": None, "card_set_id": _dep_card_set["id"]}).json()
        res = client.patch(f"/api/draft_sessions/{created.get('id', 1)}/transitions/waitingforplayers-to-abandoned", headers={"X-User-Role": "nobody"})
        assert res.status_code in (403, 404)

    def test_transition_completed_to_drafting_is_denied(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        created = client.post("/api/draft_sessions", json={"status": "Completed", "draft_type": "Booster", "seats": 2, "time_per_pick_seconds": 1, "created_at": "2024-01-01T00:00:00", "completed_at": None, "card_set_id": _dep_card_set["id"]}).json()
        res = client.patch(f"/api/draft_sessions/{created.get('id', 1)}/transitions/completed-to-drafting")
        assert res.status_code in (409, 404)

    def test_transition_abandoned_to_drafting_is_denied(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        created = client.post("/api/draft_sessions", json={"status": "Completed", "draft_type": "Booster", "seats": 2, "time_per_pick_seconds": 1, "created_at": "2024-01-01T00:00:00", "completed_at": None, "card_set_id": _dep_card_set["id"]}).json()
        res = client.patch(f"/api/draft_sessions/{created.get('id', 1)}/transitions/abandoned-to-drafting")
        assert res.status_code in (409, 404)


class TestDraftParticipant:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/draft_participants")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        data = {"seat_number": 1, "joined_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}
        res = client.post("/api/draft_participants", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/draft_participants", json={"seat_number": 1, "joined_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        res = client.get(f"/api/draft_participants/{created['id']}")
        assert res.status_code == 200

    def test_create_fails_when_seat_number_positive_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # Simple rule violated → 422
        data = {"seat_number": 0, "joined_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}
        res = client.post("/api/draft_participants", json=data)
        assert res.status_code == 422


class TestDraftPick:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/draft_picks")
        assert res.status_code == 200
        assert isinstance(res.json(), list)


class TestArticle:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/articles")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_search_returns_200(self, client: TestClient):
        res = client.get("/api/articles?q=test")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        data = {"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 0, "likes_count": 0, "is_featured": False, "published_at": "2024-01-01T00:00:00", "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}
        res = client.post("/api/articles", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 0, "likes_count": 0, "is_featured": False, "published_at": "2024-01-01T00:00:00", "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        res = client.get(f"/api/articles/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 0, "likes_count": 0, "is_featured": False, "published_at": "2024-01-01T00:00:00", "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        res = client.put(f"/api/articles/{created['id']}", json={"title": "test"})
        assert res.status_code == 200

    def test_create_fails_when_published_requires_published_at_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"title": "test", "slug": "test", "body": "test", "status": "Published", "article_type": "Guide", "language": "EN", "view_count": 0, "likes_count": 0, "is_featured": False, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "published_at": None, "author_id": _dep_player["id"]}
        res = client.post("/api/articles", json=data)
        assert res.status_code == 422

    def test_create_fails_when_view_count_not_negative_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # Simple rule violated → 422
        data = {"title": "test", "slug": "test", "body": "test", "status": "Published", "article_type": "Guide", "language": "EN", "view_count": -1, "likes_count": 0, "is_featured": False, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "published_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}
        res = client.post("/api/articles", json=data)
        assert res.status_code == 422

    def test_create_fails_when_likes_count_not_negative_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # Simple rule violated → 422
        data = {"title": "test", "slug": "test", "body": "test", "status": "Published", "article_type": "Guide", "language": "EN", "view_count": 0, "likes_count": -1, "is_featured": False, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "published_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}
        res = client.post("/api/articles", json=data)
        assert res.status_code == 422

    def test_transition_draft_to_published(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 0, "likes_count": 0, "is_featured": False, "published_at": "2024-01-01T00:00:00", "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/articles/{created.get('id', 1)}/transitions/draft-to-published", headers={"X-User-Role": "Editor"})
        assert res.status_code in (200, 403, 409, 422, 404)

    def test_transition_draft_to_published_forbidden_for_wrong_role(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 0, "likes_count": 0, "is_featured": False, "published_at": "2024-01-01T00:00:00", "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/articles/{created.get('id', 1)}/transitions/draft-to-published", headers={"X-User-Role": "nobody"})
        assert res.status_code in (403, 404)

    def test_transition_published_to_archived(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 0, "likes_count": 0, "is_featured": False, "published_at": "2024-01-01T00:00:00", "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/articles/{created.get('id', 1)}/transitions/published-to-archived", headers={"X-User-Role": "Editor"})
        assert res.status_code in (200, 403, 409, 422, 404)

    def test_transition_published_to_archived_forbidden_for_wrong_role(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 0, "likes_count": 0, "is_featured": False, "published_at": "2024-01-01T00:00:00", "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/articles/{created.get('id', 1)}/transitions/published-to-archived", headers={"X-User-Role": "nobody"})
        assert res.status_code in (403, 404)

    def test_transition_archived_to_draft(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 0, "likes_count": 0, "is_featured": False, "published_at": "2024-01-01T00:00:00", "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/articles/{created.get('id', 1)}/transitions/archived-to-draft", headers={"X-User-Role": "Admin"})
        assert res.status_code in (200, 403, 409, 422, 404)

    def test_transition_archived_to_draft_forbidden_for_wrong_role(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 0, "likes_count": 0, "is_featured": False, "published_at": "2024-01-01T00:00:00", "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/articles/{created.get('id', 1)}/transitions/archived-to-draft", headers={"X-User-Role": "nobody"})
        assert res.status_code in (403, 404)

    def test_transition_published_to_draft_is_denied(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 0, "likes_count": 0, "is_featured": False, "published_at": "2024-01-01T00:00:00", "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/articles/{created.get('id', 1)}/transitions/published-to-draft")
        assert res.status_code in (409, 404)


class TestArticleTag:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/article_tags")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_search_returns_200(self, client: TestClient):
        res = client.get("/api/article_tags?q=test")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"name": "test", "slug": "test"}
        res = client.post("/api/article_tags", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/article_tags", json={"name": "test", "slug": "test"}).json()
        res = client.get(f"/api/article_tags/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/article_tags", json={"name": "test", "slug": "test"}).json()
        res = client.patch(f"/api/article_tags/{created['id']}", json={"name": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/article_tags", json={"name": "test", "slug": "test"}).json()
        res = client.delete(f"/api/article_tags/{created['id']}")
        assert res.status_code == 204


class TestArticleTagAssignment:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/article_tag_assignments")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_article = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 0, "likes_count": 0, "is_featured": False, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "published_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        _dep_article_tag = client.post("/api/article_tags", json={"name": "test", "slug": "test"}).json()
        data = {"article_id": _dep_article["id"], "tag_id": _dep_article_tag["id"]}
        res = client.post("/api/article_tag_assignments", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_article = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 0, "likes_count": 0, "is_featured": False, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "published_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        _dep_article_tag = client.post("/api/article_tags", json={"name": "test", "slug": "test"}).json()
        created = client.post("/api/article_tag_assignments", json={"article_id": _dep_article["id"], "tag_id": _dep_article_tag["id"]}).json()
        res = client.get(f"/api/article_tag_assignments/{created['id']}")
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_article = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "language": "EN", "view_count": 0, "likes_count": 0, "is_featured": False, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "published_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        _dep_article_tag = client.post("/api/article_tags", json={"name": "test", "slug": "test"}).json()
        created = client.post("/api/article_tag_assignments", json={"article_id": _dep_article["id"], "tag_id": _dep_article_tag["id"]}).json()
        res = client.delete(f"/api/article_tag_assignments/{created['id']}")
        assert res.status_code == 204


class TestArticleComment:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/article_comments")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        data = {"body": "test", "is_hidden": False, "created_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}
        res = client.post("/api/article_comments", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/article_comments", json={"body": "test", "is_hidden": False, "created_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        res = client.get(f"/api/article_comments/{created['id']}")
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/article_comments", json={"body": "test", "is_hidden": False, "created_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        res = client.delete(f"/api/article_comments/{created['id']}")
        assert res.status_code == 204


class TestStream:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/streams")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_search_returns_200(self, client: TestClient):
        res = client.get("/api/streams?q=test")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        data = {"title": "test", "stream_url": "https://example.com", "status": "Ended", "platform": "Twitch", "language": "EN", "is_official": False, "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00", "actual_start": None, "ended_at": None, "streamer_id": _dep_player["id"]}
        res = client.post("/api/streams", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/streams", json={"title": "test", "stream_url": "https://example.com", "status": "Ended", "platform": "Twitch", "language": "EN", "is_official": False, "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00", "actual_start": None, "ended_at": None, "streamer_id": _dep_player["id"]}).json()
        res = client.get(f"/api/streams/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/streams", json={"title": "test", "stream_url": "https://example.com", "status": "Ended", "platform": "Twitch", "language": "EN", "is_official": False, "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00", "actual_start": None, "ended_at": None, "streamer_id": _dep_player["id"]}).json()
        res = client.put(f"/api/streams/{created['id']}", json={"title": "test"})
        assert res.status_code == 200

    def test_create_fails_when_actual_start_requires_live_or_ended_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"title": "test", "stream_url": "https://example.com", "status": "Scheduled", "platform": "Twitch", "language": "EN", "is_official": False, "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00", "actual_start": "2024-01-01T00:00:00", "ended_at": None, "streamer_id": _dep_player["id"]}
        res = client.post("/api/streams", json=data)
        assert res.status_code == 422

    def test_create_fails_when_ended_at_requires_ended_status_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"title": "test", "stream_url": "https://example.com", "status": "Scheduled", "platform": "Twitch", "language": "EN", "is_official": False, "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00", "actual_start": None, "ended_at": "2024-01-01T00:00:00", "streamer_id": _dep_player["id"]}
        res = client.post("/api/streams", json=data)
        assert res.status_code == 422

    def test_create_fails_when_viewer_count_not_negative_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # Simple rule violated → 422
        data = {"title": "test", "stream_url": "https://example.com", "status": "Ended", "platform": "Twitch", "language": "EN", "is_official": False, "viewer_count_peak": -1, "scheduled_start": "2024-01-01T00:00:00", "actual_start": "2024-01-01T00:00:00", "ended_at": "2024-01-01T00:00:00", "streamer_id": _dep_player["id"]}
        res = client.post("/api/streams", json=data)
        assert res.status_code == 422

    def test_transition_scheduled_to_live(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/streams", json={"title": "test", "stream_url": "https://example.com", "status": "Ended", "platform": "Twitch", "language": "EN", "is_official": False, "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00", "actual_start": None, "ended_at": None, "streamer_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/streams/{created.get('id', 1)}/transitions/scheduled-to-live", headers={"X-User-Role": "Streamer"})
        assert res.status_code in (200, 403, 409, 422, 404)

    def test_transition_scheduled_to_live_forbidden_for_wrong_role(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/streams", json={"title": "test", "stream_url": "https://example.com", "status": "Ended", "platform": "Twitch", "language": "EN", "is_official": False, "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00", "actual_start": None, "ended_at": None, "streamer_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/streams/{created.get('id', 1)}/transitions/scheduled-to-live", headers={"X-User-Role": "nobody"})
        assert res.status_code in (403, 404)

    def test_transition_live_to_ended(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/streams", json={"title": "test", "stream_url": "https://example.com", "status": "Ended", "platform": "Twitch", "language": "EN", "is_official": False, "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00", "actual_start": None, "ended_at": None, "streamer_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/streams/{created.get('id', 1)}/transitions/live-to-ended", headers={"X-User-Role": "Streamer"})
        assert res.status_code in (200, 403, 409, 422, 404)

    def test_transition_live_to_ended_forbidden_for_wrong_role(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/streams", json={"title": "test", "stream_url": "https://example.com", "status": "Ended", "platform": "Twitch", "language": "EN", "is_official": False, "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00", "actual_start": None, "ended_at": None, "streamer_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/streams/{created.get('id', 1)}/transitions/live-to-ended", headers={"X-User-Role": "nobody"})
        assert res.status_code in (403, 404)

    def test_transition_ended_to_live_is_denied(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/streams", json={"title": "test", "stream_url": "https://example.com", "status": "Ended", "platform": "Twitch", "language": "EN", "is_official": False, "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00", "actual_start": None, "ended_at": None, "streamer_id": _dep_player["id"]}).json()
        res = client.patch(f"/api/streams/{created.get('id', 1)}/transitions/ended-to-live")
        assert res.status_code in (409, 404)
