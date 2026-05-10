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


class TestDraftSession:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/draft_sessions")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"status": "test", "draft_type": "test", "seats": 0, "created_at": datetime(2024, 1, 1, 0, 0, 0)}
        res = client.post("/api/draft_sessions", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/draft_sessions", json={"status": "test", "draft_type": "test", "seats": 0, "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.get(f"/api/draft_sessions/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/draft_sessions", json={"status": "test", "draft_type": "test", "seats": 0, "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.put(f"/api/draft_sessions/{created['id']}", json={"status": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/draft_sessions", json={"status": "test", "draft_type": "test", "seats": 0, "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.delete(f"/api/draft_sessions/{created['id']}")
        assert res.status_code == 204


class TestDraftParticipant:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/draft_participants")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"seat_number": 0, "joined_at": datetime(2024, 1, 1, 0, 0, 0)}
        res = client.post("/api/draft_participants", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/draft_participants", json={"seat_number": 0, "joined_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.get(f"/api/draft_participants/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/draft_participants", json={"seat_number": 0, "joined_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.put(f"/api/draft_participants/{created['id']}", json={"seat_number": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/draft_participants", json={"seat_number": 0, "joined_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.delete(f"/api/draft_participants/{created['id']}")
        assert res.status_code == 204


class TestDraftPick:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/draft_picks")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"pick_number": 0, "pack_number": 0, "picked_at": datetime(2024, 1, 1, 0, 0, 0)}
        res = client.post("/api/draft_picks", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/draft_picks", json={"pick_number": 0, "pack_number": 0, "picked_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.get(f"/api/draft_picks/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/draft_picks", json={"pick_number": 0, "pack_number": 0, "picked_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.put(f"/api/draft_picks/{created['id']}", json={"pick_number": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/draft_picks", json={"pick_number": 0, "pack_number": 0, "picked_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.delete(f"/api/draft_picks/{created['id']}")
        assert res.status_code == 204


class TestArticle:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/articles")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"title": "test", "slug": "test", "body": "test", "status": "test", "article_type": "test", "view_count": 0, "created_at": datetime(2024, 1, 1, 0, 0, 0), "updated_at": datetime(2024, 1, 1, 0, 0, 0)}
        res = client.post("/api/articles", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "test", "article_type": "test", "view_count": 0, "created_at": datetime(2024, 1, 1, 0, 0, 0), "updated_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.get(f"/api/articles/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "test", "article_type": "test", "view_count": 0, "created_at": datetime(2024, 1, 1, 0, 0, 0), "updated_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.put(f"/api/articles/{created['id']}", json={"title": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/articles", json={"title": "test", "slug": "test", "body": "test", "status": "test", "article_type": "test", "view_count": 0, "created_at": datetime(2024, 1, 1, 0, 0, 0), "updated_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.delete(f"/api/articles/{created['id']}")
        assert res.status_code == 204


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
        data = {}
        res = client.post("/api/article_tag_assignments", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/article_tag_assignments", json={}).json()
        res = client.get(f"/api/article_tag_assignments/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/article_tag_assignments", json={}).json()
        res = client.put(f"/api/article_tag_assignments/{created['id']}", json={})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/article_tag_assignments", json={}).json()
        res = client.delete(f"/api/article_tag_assignments/{created['id']}")
        assert res.status_code == 204


class TestArticleComment:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/article_comments")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"body": "test", "is_hidden": False, "created_at": datetime(2024, 1, 1, 0, 0, 0)}
        res = client.post("/api/article_comments", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/article_comments", json={"body": "test", "is_hidden": False, "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.get(f"/api/article_comments/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/article_comments", json={"body": "test", "is_hidden": False, "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.put(f"/api/article_comments/{created['id']}", json={"body": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/article_comments", json={"body": "test", "is_hidden": False, "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.delete(f"/api/article_comments/{created['id']}")
        assert res.status_code == 204


class TestStream:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/streams")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"title": "test", "stream_url": "https://example.com", "platform": "test", "status": "test", "viewer_count_peak": 0, "scheduled_start": datetime(2024, 1, 1, 0, 0, 0)}
        res = client.post("/api/streams", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/streams", json={"title": "test", "stream_url": "https://example.com", "platform": "test", "status": "test", "viewer_count_peak": 0, "scheduled_start": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.get(f"/api/streams/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/streams", json={"title": "test", "stream_url": "https://example.com", "platform": "test", "status": "test", "viewer_count_peak": 0, "scheduled_start": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.put(f"/api/streams/{created['id']}", json={"title": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/streams", json={"title": "test", "stream_url": "https://example.com", "platform": "test", "status": "test", "viewer_count_peak": 0, "scheduled_start": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.delete(f"/api/streams/{created['id']}")
        assert res.status_code == 204
