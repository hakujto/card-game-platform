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


class TestPlayer:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/players")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_search_returns_200(self, client: TestClient):
        res = client.get("/api/players?q=test")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}
        res = client.post("/api/players", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        res = client.get(f"/api/players/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        res = client.patch(f"/api/players/{created['id']}", json={"display_name": "test"})
        assert res.status_code == 200

    def test_create_fails_when_rating_range_violated(self, client: TestClient):
        # Simple rule violated → 422
        data = {"display_name": "test", "rank": "Bronze", "rating": 10000, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}
        res = client.post("/api/players", json=data)
        assert res.status_code == 422

    def test_create_fails_when_peak_rating_gte_rating_violated(self, client: TestClient):
        # Simple rule violated → 422
        data = {"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": -1, "is_verified": False, "created_at": "2024-01-01T00:00:00"}
        res = client.post("/api/players", json=data)
        assert res.status_code == 422


class TestPlayerSeasonStats:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/player_season_statses")
        assert res.status_code == 200
        assert isinstance(res.json(), list)


class TestPlayerCollection:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/player_collections")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        data = {"quantity": 1, "foil": False, "condition": "Mint", "acquired_at": "2024-01-01T00:00:00", "acquired_via": "Purchase", "player_id": _dep_player["id"], "card_id": _dep_card["id"]}
        res = client.post("/api/player_collections", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/player_collections", json={"quantity": 1, "foil": False, "condition": "Mint", "acquired_at": "2024-01-01T00:00:00", "acquired_via": "Purchase", "player_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        res = client.get(f"/api/player_collections/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/player_collections", json={"quantity": 1, "foil": False, "condition": "Mint", "acquired_at": "2024-01-01T00:00:00", "acquired_via": "Purchase", "player_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        res = client.patch(f"/api/player_collections/{created['id']}", json={"quantity": 1})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/player_collections", json={"quantity": 1, "foil": False, "condition": "Mint", "acquired_at": "2024-01-01T00:00:00", "acquired_via": "Purchase", "player_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        res = client.delete(f"/api/player_collections/{created['id']}")
        assert res.status_code == 204

    def test_create_fails_when_quantity_positive_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        # Simple rule violated → 422
        data = {"quantity": 0, "foil": False, "condition": "Mint", "acquired_at": "2024-01-01T00:00:00", "acquired_via": "Purchase", "player_id": _dep_player["id"], "card_id": _dep_card["id"]}
        res = client.post("/api/player_collections", json=data)
        assert res.status_code == 422


class TestFriendship:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/friendships")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        data = {"status": "Pending", "created_at": "2024-01-01T00:00:00", "requester_id": _dep_player["id"], "receiver_id": _dep_player["id"]}
        res = client.post("/api/friendships", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/friendships", json={"status": "Pending", "created_at": "2024-01-01T00:00:00", "requester_id": _dep_player["id"], "receiver_id": _dep_player["id"]}).json()
        res = client.get(f"/api/friendships/{created['id']}")
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/friendships", json={"status": "Pending", "created_at": "2024-01-01T00:00:00", "requester_id": _dep_player["id"], "receiver_id": _dep_player["id"]}).json()
        res = client.delete(f"/api/friendships/{created['id']}")
        assert res.status_code == 204


class TestAchievement:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/achievements")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_search_returns_200(self, client: TestClient):
        res = client.get("/api/achievements?q=test")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"name": "test", "description": "test", "points": 1, "rarity": "Common", "is_hidden": False}
        res = client.post("/api/achievements", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/achievements", json={"name": "test", "description": "test", "points": 1, "rarity": "Common", "is_hidden": False}).json()
        res = client.get(f"/api/achievements/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/achievements", json={"name": "test", "description": "test", "points": 1, "rarity": "Common", "is_hidden": False}).json()
        res = client.put(f"/api/achievements/{created['id']}", json={"name": "test"})
        assert res.status_code == 200

    def test_create_fails_when_points_positive_violated(self, client: TestClient):
        # Simple rule violated → 422
        data = {"name": "test", "description": "test", "points": 0, "rarity": "Common", "is_hidden": False}
        res = client.post("/api/achievements", json=data)
        assert res.status_code == 422


class TestPlayerAchievement:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/player_achievements")
        assert res.status_code == 200
        assert isinstance(res.json(), list)


class TestCraftingRecipe:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/crafting_recipes")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        data = {"dust_cost": 1, "is_available": False, "result_card_id": _dep_card["id"]}
        res = client.post("/api/crafting_recipes", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/crafting_recipes", json={"dust_cost": 1, "is_available": False, "result_card_id": _dep_card["id"]}).json()
        res = client.get(f"/api/crafting_recipes/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/crafting_recipes", json={"dust_cost": 1, "is_available": False, "result_card_id": _dep_card["id"]}).json()
        res = client.put(f"/api/crafting_recipes/{created['id']}", json={"dust_cost": 1})
        assert res.status_code == 200

    def test_create_fails_when_dust_cost_positive_violated(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        # Simple rule violated → 422
        data = {"dust_cost": 0, "is_available": False, "result_card_id": _dep_card["id"]}
        res = client.post("/api/crafting_recipes", json=data)
        assert res.status_code == 422


class TestCraftingIngredient:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/crafting_ingredients")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_crafting_recipe = client.post("/api/crafting_recipes", json={"dust_cost": 1, "is_available": False, "result_card_id": _dep_card["id"]}).json()
        data = {"quantity": 0, "recipe_id": _dep_crafting_recipe["id"], "card_id": _dep_card["id"]}
        res = client.post("/api/crafting_ingredients", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_crafting_recipe = client.post("/api/crafting_recipes", json={"dust_cost": 1, "is_available": False, "result_card_id": _dep_card["id"]}).json()
        created = client.post("/api/crafting_ingredients", json={"quantity": 0, "recipe_id": _dep_crafting_recipe["id"], "card_id": _dep_card["id"]}).json()
        res = client.get(f"/api/crafting_ingredients/{created['id']}")
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_crafting_recipe = client.post("/api/crafting_recipes", json={"dust_cost": 1, "is_available": False, "result_card_id": _dep_card["id"]}).json()
        created = client.post("/api/crafting_ingredients", json={"quantity": 0, "recipe_id": _dep_crafting_recipe["id"], "card_id": _dep_card["id"]}).json()
        res = client.delete(f"/api/crafting_ingredients/{created['id']}")
        assert res.status_code == 204
