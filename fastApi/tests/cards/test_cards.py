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


class TestCard:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/cards")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"name": "test", "card_type": "test", "rarity": "test", "mana_cost": 0, "mana_colors": "test", "description": "test", "legal_formats": "test", "is_banned": False, "is_restricted": False, "power_level": 0}
        res = client.post("/api/cards", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/cards", json={"name": "test", "card_type": "test", "rarity": "test", "mana_cost": 0, "mana_colors": "test", "description": "test", "legal_formats": "test", "is_banned": False, "is_restricted": False, "power_level": 0}).json()
        res = client.get(f"/api/cards/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/cards", json={"name": "test", "card_type": "test", "rarity": "test", "mana_cost": 0, "mana_colors": "test", "description": "test", "legal_formats": "test", "is_banned": False, "is_restricted": False, "power_level": 0}).json()
        res = client.put(f"/api/cards/{created['id']}", json={"name": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/cards", json={"name": "test", "card_type": "test", "rarity": "test", "mana_cost": 0, "mana_colors": "test", "description": "test", "legal_formats": "test", "is_banned": False, "is_restricted": False, "power_level": 0}).json()
        res = client.delete(f"/api/cards/{created['id']}")
        assert res.status_code == 204


class TestCardSet:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/card_sets")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"name": "test", "code": "test", "release_date": date(2024, 1, 1), "set_type": "test", "total_cards": 0}
        res = client.post("/api/card_sets", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": date(2024, 1, 1), "set_type": "test", "total_cards": 0}).json()
        res = client.get(f"/api/card_sets/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": date(2024, 1, 1), "set_type": "test", "total_cards": 0}).json()
        res = client.put(f"/api/card_sets/{created['id']}", json={"name": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": date(2024, 1, 1), "set_type": "test", "total_cards": 0}).json()
        res = client.delete(f"/api/card_sets/{created['id']}")
        assert res.status_code == 204


class TestCardRuling:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/card_rulings")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"ruling_text": "test", "published_at": date(2024, 1, 1), "source": "test"}
        res = client.post("/api/card_rulings", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/card_rulings", json={"ruling_text": "test", "published_at": date(2024, 1, 1), "source": "test"}).json()
        res = client.get(f"/api/card_rulings/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/card_rulings", json={"ruling_text": "test", "published_at": date(2024, 1, 1), "source": "test"}).json()
        res = client.put(f"/api/card_rulings/{created['id']}", json={"ruling_text": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/card_rulings", json={"ruling_text": "test", "published_at": date(2024, 1, 1), "source": "test"}).json()
        res = client.delete(f"/api/card_rulings/{created['id']}")
        assert res.status_code == 204


class TestCardAbility:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/card_abilities")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"ability_type": "test", "ability_text": "test"}
        res = client.post("/api/card_abilities", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/card_abilities", json={"ability_type": "test", "ability_text": "test"}).json()
        res = client.get(f"/api/card_abilities/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/card_abilities", json={"ability_type": "test", "ability_text": "test"}).json()
        res = client.put(f"/api/card_abilities/{created['id']}", json={"ability_type": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/card_abilities", json={"ability_type": "test", "ability_text": "test"}).json()
        res = client.delete(f"/api/card_abilities/{created['id']}")
        assert res.status_code == 204


class TestDeck:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/decks")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"name": "test", "format": "test", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": datetime(2024, 1, 1, 0, 0, 0), "updated_at": datetime(2024, 1, 1, 0, 0, 0)}
        res = client.post("/api/decks", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/decks", json={"name": "test", "format": "test", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": datetime(2024, 1, 1, 0, 0, 0), "updated_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.get(f"/api/decks/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/decks", json={"name": "test", "format": "test", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": datetime(2024, 1, 1, 0, 0, 0), "updated_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.put(f"/api/decks/{created['id']}", json={"name": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/decks", json={"name": "test", "format": "test", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": datetime(2024, 1, 1, 0, 0, 0), "updated_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.delete(f"/api/decks/{created['id']}")
        assert res.status_code == 204


class TestDeckCard:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/deck_cards")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"quantity": 0, "is_commander": False}
        res = client.post("/api/deck_cards", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/deck_cards", json={"quantity": 0, "is_commander": False}).json()
        res = client.get(f"/api/deck_cards/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/deck_cards", json={"quantity": 0, "is_commander": False}).json()
        res = client.put(f"/api/deck_cards/{created['id']}", json={"quantity": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/deck_cards", json={"quantity": 0, "is_commander": False}).json()
        res = client.delete(f"/api/deck_cards/{created['id']}")
        assert res.status_code == 204


class TestDeckSideboardCard:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/deck_sideboard_cards")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"quantity": 0}
        res = client.post("/api/deck_sideboard_cards", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/deck_sideboard_cards", json={"quantity": 0}).json()
        res = client.get(f"/api/deck_sideboard_cards/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/deck_sideboard_cards", json={"quantity": 0}).json()
        res = client.put(f"/api/deck_sideboard_cards/{created['id']}", json={"quantity": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/deck_sideboard_cards", json={"quantity": 0}).json()
        res = client.delete(f"/api/deck_sideboard_cards/{created['id']}")
        assert res.status_code == 204


class TestDeckTag:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/deck_tags")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"name": "test"}
        res = client.post("/api/deck_tags", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/deck_tags", json={"name": "test"}).json()
        res = client.get(f"/api/deck_tags/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/deck_tags", json={"name": "test"}).json()
        res = client.put(f"/api/deck_tags/{created['id']}", json={"name": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/deck_tags", json={"name": "test"}).json()
        res = client.delete(f"/api/deck_tags/{created['id']}")
        assert res.status_code == 204


class TestDeckTagAssignment:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/deck_tag_assignments")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {}
        res = client.post("/api/deck_tag_assignments", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/deck_tag_assignments", json={}).json()
        res = client.get(f"/api/deck_tag_assignments/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/deck_tag_assignments", json={}).json()
        res = client.put(f"/api/deck_tag_assignments/{created['id']}", json={})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/deck_tag_assignments", json={}).json()
        res = client.delete(f"/api/deck_tag_assignments/{created['id']}")
        assert res.status_code == 204
