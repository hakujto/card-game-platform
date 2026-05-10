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


class TestPlayer:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/players")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"display_name": "test", "rank": "test", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": datetime(2024, 1, 1, 0, 0, 0)}
        res = client.post("/api/players", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/players", json={"display_name": "test", "rank": "test", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.get(f"/api/players/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/players", json={"display_name": "test", "rank": "test", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.put(f"/api/players/{created['id']}", json={"display_name": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/players", json={"display_name": "test", "rank": "test", "rating": 0, "peak_rating": 0, "is_verified": False, "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.delete(f"/api/players/{created['id']}")
        assert res.status_code == 204


class TestPlayerSeasonStats:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/player_season_statses")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"wins": 0, "losses": 0, "draws": 0, "tournament_wins": 0, "season_points": 0}
        res = client.post("/api/player_season_statses", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/player_season_statses", json={"wins": 0, "losses": 0, "draws": 0, "tournament_wins": 0, "season_points": 0}).json()
        res = client.get(f"/api/player_season_statses/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/player_season_statses", json={"wins": 0, "losses": 0, "draws": 0, "tournament_wins": 0, "season_points": 0}).json()
        res = client.put(f"/api/player_season_statses/{created['id']}", json={"wins": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/player_season_statses", json={"wins": 0, "losses": 0, "draws": 0, "tournament_wins": 0, "season_points": 0}).json()
        res = client.delete(f"/api/player_season_statses/{created['id']}")
        assert res.status_code == 204


class TestPlayerCollection:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/player_collections")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"quantity": 0, "foil": False, "condition": "test", "acquired_at": datetime(2024, 1, 1, 0, 0, 0), "acquired_via": "test"}
        res = client.post("/api/player_collections", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/player_collections", json={"quantity": 0, "foil": False, "condition": "test", "acquired_at": datetime(2024, 1, 1, 0, 0, 0), "acquired_via": "test"}).json()
        res = client.get(f"/api/player_collections/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/player_collections", json={"quantity": 0, "foil": False, "condition": "test", "acquired_at": datetime(2024, 1, 1, 0, 0, 0), "acquired_via": "test"}).json()
        res = client.put(f"/api/player_collections/{created['id']}", json={"quantity": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/player_collections", json={"quantity": 0, "foil": False, "condition": "test", "acquired_at": datetime(2024, 1, 1, 0, 0, 0), "acquired_via": "test"}).json()
        res = client.delete(f"/api/player_collections/{created['id']}")
        assert res.status_code == 204


class TestFriendship:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/friendships")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"status": "test", "created_at": datetime(2024, 1, 1, 0, 0, 0)}
        res = client.post("/api/friendships", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/friendships", json={"status": "test", "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.get(f"/api/friendships/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/friendships", json={"status": "test", "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.put(f"/api/friendships/{created['id']}", json={"status": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/friendships", json={"status": "test", "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.delete(f"/api/friendships/{created['id']}")
        assert res.status_code == 204


class TestAchievement:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/achievements")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"name": "test", "description": "test", "points": 0, "rarity": "test", "is_hidden": False}
        res = client.post("/api/achievements", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/achievements", json={"name": "test", "description": "test", "points": 0, "rarity": "test", "is_hidden": False}).json()
        res = client.get(f"/api/achievements/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/achievements", json={"name": "test", "description": "test", "points": 0, "rarity": "test", "is_hidden": False}).json()
        res = client.put(f"/api/achievements/{created['id']}", json={"name": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/achievements", json={"name": "test", "description": "test", "points": 0, "rarity": "test", "is_hidden": False}).json()
        res = client.delete(f"/api/achievements/{created['id']}")
        assert res.status_code == 204


class TestPlayerAchievement:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/player_achievements")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"earned_at": datetime(2024, 1, 1, 0, 0, 0), "progress": 0, "is_completed": False}
        res = client.post("/api/player_achievements", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/player_achievements", json={"earned_at": datetime(2024, 1, 1, 0, 0, 0), "progress": 0, "is_completed": False}).json()
        res = client.get(f"/api/player_achievements/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/player_achievements", json={"earned_at": datetime(2024, 1, 1, 0, 0, 0), "progress": 0, "is_completed": False}).json()
        res = client.put(f"/api/player_achievements/{created['id']}", json={"earned_at": datetime(2024, 1, 1, 0, 0, 0)})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/player_achievements", json={"earned_at": datetime(2024, 1, 1, 0, 0, 0), "progress": 0, "is_completed": False}).json()
        res = client.delete(f"/api/player_achievements/{created['id']}")
        assert res.status_code == 204


class TestCraftingRecipe:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/crafting_recipes")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"dust_cost": 0, "is_available": False}
        res = client.post("/api/crafting_recipes", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/crafting_recipes", json={"dust_cost": 0, "is_available": False}).json()
        res = client.get(f"/api/crafting_recipes/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/crafting_recipes", json={"dust_cost": 0, "is_available": False}).json()
        res = client.put(f"/api/crafting_recipes/{created['id']}", json={"dust_cost": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/crafting_recipes", json={"dust_cost": 0, "is_available": False}).json()
        res = client.delete(f"/api/crafting_recipes/{created['id']}")
        assert res.status_code == 204


class TestCraftingIngredient:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/crafting_ingredients")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"quantity": 0}
        res = client.post("/api/crafting_ingredients", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/crafting_ingredients", json={"quantity": 0}).json()
        res = client.get(f"/api/crafting_ingredients/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/crafting_ingredients", json={"quantity": 0}).json()
        res = client.put(f"/api/crafting_ingredients/{created['id']}", json={"quantity": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/crafting_ingredients", json={"quantity": 0}).json()
        res = client.delete(f"/api/crafting_ingredients/{created['id']}")
        assert res.status_code == 204
