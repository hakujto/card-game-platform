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


class TestCard:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/cards")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        data = {"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}
        res = client.post("/api/cards", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        created = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        res = client.get(f"/api/cards/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        created = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        res = client.put(f"/api/cards/{created['id']}", json={"name": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        created = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        res = client.delete(f"/api/cards/{created['id']}")
        assert res.status_code == 204


class TestCardSet:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/card_sets")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}
        res = client.post("/api/card_sets", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        res = client.get(f"/api/card_sets/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        res = client.put(f"/api/card_sets/{created['id']}", json={"name": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        res = client.delete(f"/api/card_sets/{created['id']}")
        assert res.status_code == 204


class TestCardRuling:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/card_rulings")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        data = {"ruling_text": "test", "published_at": "2024-01-01", "source": "test", "card_id": _dep_card["id"]}
        res = client.post("/api/card_rulings", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/card_rulings", json={"ruling_text": "test", "published_at": "2024-01-01", "source": "test", "card_id": _dep_card["id"]}).json()
        res = client.get(f"/api/card_rulings/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/card_rulings", json={"ruling_text": "test", "published_at": "2024-01-01", "source": "test", "card_id": _dep_card["id"]}).json()
        res = client.put(f"/api/card_rulings/{created['id']}", json={"ruling_text": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/card_rulings", json={"ruling_text": "test", "published_at": "2024-01-01", "source": "test", "card_id": _dep_card["id"]}).json()
        res = client.delete(f"/api/card_rulings/{created['id']}")
        assert res.status_code == 204


class TestCardAbility:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/card_abilities")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        data = {"ability_type": "Keyword", "ability_text": "test", "card_id": _dep_card["id"]}
        res = client.post("/api/card_abilities", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/card_abilities", json={"ability_type": "Keyword", "ability_text": "test", "card_id": _dep_card["id"]}).json()
        res = client.get(f"/api/card_abilities/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/card_abilities", json={"ability_type": "Keyword", "ability_text": "test", "card_id": _dep_card["id"]}).json()
        res = client.put(f"/api/card_abilities/{created['id']}", json={"keyword": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/card_abilities", json={"ability_type": "Keyword", "ability_text": "test", "card_id": _dep_card["id"]}).json()
        res = client.delete(f"/api/card_abilities/{created['id']}")
        assert res.status_code == 204


class TestDeck:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/decks")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        data = {"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}
        res = client.post("/api/decks", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        res = client.get(f"/api/decks/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        res = client.put(f"/api/decks/{created['id']}", json={"name": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        res = client.delete(f"/api/decks/{created['id']}")
        assert res.status_code == 204


class TestDeckCard:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/deck_cards")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        data = {"quantity": 0, "is_commander": False, "deck_id": _dep_deck["id"], "card_id": _dep_card["id"]}
        res = client.post("/api/deck_cards", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/deck_cards", json={"quantity": 0, "is_commander": False, "deck_id": _dep_deck["id"], "card_id": _dep_card["id"]}).json()
        res = client.get(f"/api/deck_cards/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/deck_cards", json={"quantity": 0, "is_commander": False, "deck_id": _dep_deck["id"], "card_id": _dep_card["id"]}).json()
        res = client.put(f"/api/deck_cards/{created['id']}", json={"quantity": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/deck_cards", json={"quantity": 0, "is_commander": False, "deck_id": _dep_deck["id"], "card_id": _dep_card["id"]}).json()
        res = client.delete(f"/api/deck_cards/{created['id']}")
        assert res.status_code == 204


class TestDeckSideboardCard:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/deck_sideboard_cards")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        data = {"quantity": 0, "deck_id": _dep_deck["id"], "card_id": _dep_card["id"]}
        res = client.post("/api/deck_sideboard_cards", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/deck_sideboard_cards", json={"quantity": 0, "deck_id": _dep_deck["id"], "card_id": _dep_card["id"]}).json()
        res = client.get(f"/api/deck_sideboard_cards/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/deck_sideboard_cards", json={"quantity": 0, "deck_id": _dep_deck["id"], "card_id": _dep_card["id"]}).json()
        res = client.put(f"/api/deck_sideboard_cards/{created['id']}", json={"quantity": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 0}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 0, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/deck_sideboard_cards", json={"quantity": 0, "deck_id": _dep_deck["id"], "card_id": _dep_card["id"]}).json()
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
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        _dep_deck_tag = client.post("/api/deck_tags", json={"name": "test"}).json()
        data = {"deck_id": _dep_deck["id"], "tag_id": _dep_deck_tag["id"]}
        res = client.post("/api/deck_tag_assignments", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        _dep_deck_tag = client.post("/api/deck_tags", json={"name": "test"}).json()
        created = client.post("/api/deck_tag_assignments", json={"deck_id": _dep_deck["id"], "tag_id": _dep_deck_tag["id"]}).json()
        res = client.get(f"/api/deck_tag_assignments/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        _dep_deck_tag = client.post("/api/deck_tags", json={"name": "test"}).json()
        created = client.post("/api/deck_tag_assignments", json={"deck_id": _dep_deck["id"], "tag_id": _dep_deck_tag["id"]}).json()
        res = client.put(f"/api/deck_tag_assignments/{created['id']}", json={})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_deck = client.post("/api/decks", json={"name": "test", "format": "Standard", "is_public": False, "is_tournament_legal": False, "wins": 0, "losses": 0, "created_at": "2024-01-01T00:00:00", "updated_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}).json()
        _dep_deck_tag = client.post("/api/deck_tags", json={"name": "test"}).json()
        created = client.post("/api/deck_tag_assignments", json={"deck_id": _dep_deck["id"], "tag_id": _dep_deck_tag["id"]}).json()
        res = client.delete(f"/api/deck_tag_assignments/{created['id']}")
        assert res.status_code == 204
