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
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        data = {"status": "WaitingForPlayers", "draft_type": "Booster", "seats": 0, "created_at": "2024-01-01T00:00:00", "card_set_id": _dep_card_set["id"]}
        res = client.post("/api/draft_sessions", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        created = client.post("/api/draft_sessions", json={"status": "WaitingForPlayers", "draft_type": "Booster", "seats": 0, "created_at": "2024-01-01T00:00:00", "card_set_id": _dep_card_set["id"]}).json()
        res = client.get(f"/api/draft_sessions/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        created = client.post("/api/draft_sessions", json={"status": "WaitingForPlayers", "draft_type": "Booster", "seats": 0, "created_at": "2024-01-01T00:00:00", "card_set_id": _dep_card_set["id"]}).json()
        res = client.put(f"/api/draft_sessions/{created['id']}", json={"seats": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        created = client.post("/api/draft_sessions", json={"status": "WaitingForPlayers", "draft_type": "Booster", "seats": 0, "created_at": "2024-01-01T00:00:00", "card_set_id": _dep_card_set["id"]}).json()
        res = client.delete(f"/api/draft_sessions/{created['id']}")
        assert res.status_code == 204


class TestDraftParticipant:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/draft_participants")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        data = {"seat_number": 0, "joined_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}
        res = client.post("/api/draft_participants", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/draft_participants", json={"seat_number": 0, "joined_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        res = client.get(f"/api/draft_participants/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/draft_participants", json={"seat_number": 0, "joined_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        res = client.put(f"/api/draft_participants/{created['id']}", json={"seat_number": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/draft_participants", json={"seat_number": 0, "joined_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        res = client.delete(f"/api/draft_participants/{created['id']}")
        assert res.status_code == 204


class TestDraftPick:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/draft_picks")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_draft_participant = client.post("/api/draft_participants", json={"seat_number": 0, "joined_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": 0, "set_id": _dep_card_set["id"]}).json()
        data = {"pick_number": 0, "pack_number": 0, "picked_at": "2024-01-01T00:00:00", "participant_id": _dep_draft_participant["id"], "card_id": _dep_card["id"]}
        res = client.post("/api/draft_picks", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_draft_participant = client.post("/api/draft_participants", json={"seat_number": 0, "joined_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": 0, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/draft_picks", json={"pick_number": 0, "pack_number": 0, "picked_at": "2024-01-01T00:00:00", "participant_id": _dep_draft_participant["id"], "card_id": _dep_card["id"]}).json()
        res = client.get(f"/api/draft_picks/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_draft_participant = client.post("/api/draft_participants", json={"seat_number": 0, "joined_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": 0, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/draft_picks", json={"pick_number": 0, "pack_number": 0, "picked_at": "2024-01-01T00:00:00", "participant_id": _dep_draft_participant["id"], "card_id": _dep_card["id"]}).json()
        res = client.put(f"/api/draft_picks/{created['id']}", json={"pick_number": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_draft_participant = client.post("/api/draft_participants", json={"seat_number": 0, "joined_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": 0, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/draft_picks", json={"pick_number": 0, "pack_number": 0, "picked_at": "2024-01-01T00:00:00", "participant_id": _dep_draft_participant["id"], "card_id": _dep_card["id"]}).json()
        res = client.delete(f"/api/draft_picks/{created['id']}")
        assert res.status_code == 204


class TestArticle:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/articles")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        data = {"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "view_count": 0, "published_at": "2024-01-01T00:00:00", "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}
        res = client.post("/api/articles", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "view_count": 0, "published_at": "2024-01-01T00:00:00", "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        res = client.get(f"/api/articles/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "view_count": 0, "published_at": "2024-01-01T00:00:00", "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        res = client.put(f"/api/articles/{created['id']}", json={"title": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "view_count": 0, "published_at": "2024-01-01T00:00:00", "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        res = client.delete(f"/api/articles/{created['id']}")
        assert res.status_code == 204

    def test_create_fails_when_published_requires_published_at_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"title": "test", "slug": "test", "body": "test", "status": "Published", "article_type": "Guide", "view_count": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "published_at": None, "author_id": _dep_player["id"]}
        res = client.post("/api/articles", json=data)
        assert res.status_code == 422


class TestArticleTag:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/article_tags")
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
        res = client.put(f"/api/article_tags/{created['id']}", json={"name": "test"})
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
        _dep_article = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "view_count": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "published_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        _dep_article_tag = client.post("/api/article_tags", json={"name": "test", "slug": "test"}).json()
        data = {"article_id": _dep_article["id"], "tag_id": _dep_article_tag["id"]}
        res = client.post("/api/article_tag_assignments", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_article = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "view_count": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "published_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        _dep_article_tag = client.post("/api/article_tags", json={"name": "test", "slug": "test"}).json()
        created = client.post("/api/article_tag_assignments", json={"article_id": _dep_article["id"], "tag_id": _dep_article_tag["id"]}).json()
        res = client.get(f"/api/article_tag_assignments/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_article = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "view_count": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "published_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        _dep_article_tag = client.post("/api/article_tags", json={"name": "test", "slug": "test"}).json()
        created = client.post("/api/article_tag_assignments", json={"article_id": _dep_article["id"], "tag_id": _dep_article_tag["id"]}).json()
        res = client.put(f"/api/article_tag_assignments/{created['id']}", json={})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_article = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "Draft", "article_type": "Guide", "view_count": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "published_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
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

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/article_comments", json={"body": "test", "is_hidden": False, "created_at": "2024-01-01T00:00:00", "author_id": _dep_player["id"]}).json()
        res = client.put(f"/api/article_comments/{created['id']}", json={"body": "test"})
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

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        data = {"title": "test", "stream_url": "https://example.com", "platform": "Twitch", "status": "Scheduled", "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00", "streamer_id": _dep_player["id"]}
        res = client.post("/api/streams", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/streams", json={"title": "test", "stream_url": "https://example.com", "platform": "Twitch", "status": "Scheduled", "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00", "streamer_id": _dep_player["id"]}).json()
        res = client.get(f"/api/streams/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/streams", json={"title": "test", "stream_url": "https://example.com", "platform": "Twitch", "status": "Scheduled", "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00", "streamer_id": _dep_player["id"]}).json()
        res = client.put(f"/api/streams/{created['id']}", json={"title": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/streams", json={"title": "test", "stream_url": "https://example.com", "platform": "Twitch", "status": "Scheduled", "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00", "streamer_id": _dep_player["id"]}).json()
        res = client.delete(f"/api/streams/{created['id']}")
        assert res.status_code == 204

    def test_create_fails_when_actual_start_requires_live_or_ended_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"title": "test", "stream_url": "https://example.com", "platform": "Twitch", "status": "Scheduled", "viewer_count_peak": 0, "scheduled_start": "2024-01-01T00:00:00", "streamer_id": _dep_player["id"], "actual_start": "2024-01-01T00:00:00"}
        res = client.post("/api/streams", json=data)
        assert res.status_code == 422
