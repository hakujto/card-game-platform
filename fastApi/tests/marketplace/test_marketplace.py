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


class TestProduct:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/products")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"name": "test", "product_type": "SingleCard", "price": 1, "stock": 0, "active": False, "discount_percent": 0, "featured": False}
        res = client.post("/api/products", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/products", json={"name": "test", "product_type": "SingleCard", "price": 1, "stock": 0, "active": False, "discount_percent": 0, "featured": False}).json()
        res = client.get(f"/api/products/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/products", json={"name": "test", "product_type": "SingleCard", "price": 1, "stock": 0, "active": False, "discount_percent": 0, "featured": False}).json()
        res = client.put(f"/api/products/{created['id']}", json={"name": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/products", json={"name": "test", "product_type": "SingleCard", "price": 1, "stock": 0, "active": False, "discount_percent": 0, "featured": False}).json()
        res = client.delete(f"/api/products/{created['id']}")
        assert res.status_code == 204

    def test_create_fails_when_price_positive_violated(self, client: TestClient):
        # Simple rule violated → 422
        data = {"name": "test", "product_type": "SingleCard", "price": 0, "stock": 0, "active": False, "discount_percent": 0, "featured": False}
        res = client.post("/api/products", json=data)
        assert res.status_code == 422

    def test_create_fails_when_stock_not_negative_violated(self, client: TestClient):
        # Simple rule violated → 422
        data = {"name": "test", "product_type": "SingleCard", "price": 1, "stock": -1, "active": False, "discount_percent": 0, "featured": False}
        res = client.post("/api/products", json=data)
        assert res.status_code == 422

    def test_create_fails_when_discount_percent_range_violated(self, client: TestClient):
        # Simple rule violated → 422
        data = {"name": "test", "product_type": "SingleCard", "price": 1, "stock": 0, "active": False, "discount_percent": 101, "featured": False}
        res = client.post("/api/products", json=data)
        assert res.status_code == 422


class TestOrder:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/orders")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        data = {"status": "Shipped", "total": 0, "discount_applied": 0.0, "currency": "xxx", "tracking_number": "test", "created_at": "2024-01-01T00:00:00", "paid_at": "2024-01-01T00:00:00", "shipped_at": None, "player_id": _dep_player["id"]}
        res = client.post("/api/orders", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/orders", json={"status": "Shipped", "total": 0, "discount_applied": 0.0, "currency": "xxx", "tracking_number": "test", "created_at": "2024-01-01T00:00:00", "paid_at": "2024-01-01T00:00:00", "shipped_at": None, "player_id": _dep_player["id"]}).json()
        res = client.get(f"/api/orders/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/orders", json={"status": "Shipped", "total": 0, "discount_applied": 0.0, "currency": "xxx", "tracking_number": "test", "created_at": "2024-01-01T00:00:00", "paid_at": "2024-01-01T00:00:00", "shipped_at": None, "player_id": _dep_player["id"]}).json()
        res = client.put(f"/api/orders/{created['id']}", json={"total": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        created = client.post("/api/orders", json={"status": "Shipped", "total": 0, "discount_applied": 0.0, "currency": "xxx", "tracking_number": "test", "created_at": "2024-01-01T00:00:00", "paid_at": "2024-01-01T00:00:00", "shipped_at": None, "player_id": _dep_player["id"]}).json()
        res = client.delete(f"/api/orders/{created['id']}")
        assert res.status_code == 204

    def test_create_fails_when_paid_requires_paid_at_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"status": "Paid", "total": 0, "discount_applied": 0.0, "currency": "xxx", "created_at": "2024-01-01T00:00:00", "paid_at": None, "tracking_number": "test", "shipped_at": None, "player_id": _dep_player["id"]}
        res = client.post("/api/orders", json=data)
        assert res.status_code == 422

    def test_create_fails_when_shipped_requires_tracking_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"status": "Shipped", "total": 0, "discount_applied": 0.0, "currency": "xxx", "created_at": "2024-01-01T00:00:00", "paid_at": "2024-01-01T00:00:00", "tracking_number": None, "shipped_at": None, "player_id": _dep_player["id"]}
        res = client.post("/api/orders", json=data)
        assert res.status_code == 422

    def test_create_fails_when_shipped_at_requires_shipped_status_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"status": "Pending", "total": 0, "discount_applied": 0.0, "currency": "xxx", "created_at": "2024-01-01T00:00:00", "paid_at": "2024-01-01T00:00:00", "tracking_number": "test", "shipped_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}
        res = client.post("/api/orders", json=data)
        assert res.status_code == 422

    def test_create_fails_when_total_not_negative_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # Simple rule violated → 422
        data = {"status": "Shipped", "total": -1, "discount_applied": 0.0, "currency": "xxx", "created_at": "2024-01-01T00:00:00", "paid_at": "2024-01-01T00:00:00", "tracking_number": "test", "shipped_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}
        res = client.post("/api/orders", json=data)
        assert res.status_code == 422

    def test_create_fails_when_discount_not_exceed_total_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        # Simple rule violated → 422
        data = {"status": "Shipped", "total": 1, "discount_applied": 99999, "currency": "xxx", "created_at": "2024-01-01T00:00:00", "paid_at": "2024-01-01T00:00:00", "tracking_number": "test", "shipped_at": "2024-01-01T00:00:00", "player_id": _dep_player["id"]}
        res = client.post("/api/orders", json=data)
        assert res.status_code == 422


class TestOrderItem:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/order_items")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_product = client.post("/api/products", json={"name": "test", "product_type": "SingleCard", "price": 1, "stock": 0, "active": False, "discount_percent": 0, "featured": False}).json()
        data = {"quantity": 1, "price_at_purchase": 0, "foil": False, "product_id": _dep_product["id"]}
        res = client.post("/api/order_items", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_product = client.post("/api/products", json={"name": "test", "product_type": "SingleCard", "price": 1, "stock": 0, "active": False, "discount_percent": 0, "featured": False}).json()
        created = client.post("/api/order_items", json={"quantity": 1, "price_at_purchase": 0, "foil": False, "product_id": _dep_product["id"]}).json()
        res = client.get(f"/api/order_items/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_product = client.post("/api/products", json={"name": "test", "product_type": "SingleCard", "price": 1, "stock": 0, "active": False, "discount_percent": 0, "featured": False}).json()
        created = client.post("/api/order_items", json={"quantity": 1, "price_at_purchase": 0, "foil": False, "product_id": _dep_product["id"]}).json()
        res = client.put(f"/api/order_items/{created['id']}", json={"quantity": 1})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_product = client.post("/api/products", json={"name": "test", "product_type": "SingleCard", "price": 1, "stock": 0, "active": False, "discount_percent": 0, "featured": False}).json()
        created = client.post("/api/order_items", json={"quantity": 1, "price_at_purchase": 0, "foil": False, "product_id": _dep_product["id"]}).json()
        res = client.delete(f"/api/order_items/{created['id']}")
        assert res.status_code == 204

    def test_create_fails_when_quantity_positive_violated(self, client: TestClient):
        _dep_product = client.post("/api/products", json={"name": "test", "product_type": "SingleCard", "price": 1, "stock": 0, "active": False, "discount_percent": 0, "featured": False}).json()
        # Simple rule violated → 422
        data = {"quantity": 0, "price_at_purchase": 0, "foil": False, "product_id": _dep_product["id"]}
        res = client.post("/api/order_items", json=data)
        assert res.status_code == 422

    def test_create_fails_when_price_not_negative_violated(self, client: TestClient):
        _dep_product = client.post("/api/products", json={"name": "test", "product_type": "SingleCard", "price": 1, "stock": 0, "active": False, "discount_percent": 0, "featured": False}).json()
        # Simple rule violated → 422
        data = {"quantity": 1, "price_at_purchase": -1, "foil": False, "product_id": _dep_product["id"]}
        res = client.post("/api/order_items", json=data)
        assert res.status_code == 422


class TestCoupon:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/coupons")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"code": "test", "discount_type": "Percent", "discount_value": 1, "min_order_value": 0.0, "max_uses": None, "uses_count": 0, "valid_from": "2024-01-01T00:00:00", "valid_until": "2024-01-01T00:00:01", "is_active": False}
        res = client.post("/api/coupons", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/coupons", json={"code": "test", "discount_type": "Percent", "discount_value": 1, "min_order_value": 0.0, "max_uses": None, "uses_count": 0, "valid_from": "2024-01-01T00:00:00", "valid_until": "2024-01-01T00:00:01", "is_active": False}).json()
        res = client.get(f"/api/coupons/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/coupons", json={"code": "test", "discount_type": "Percent", "discount_value": 1, "min_order_value": 0.0, "max_uses": None, "uses_count": 0, "valid_from": "2024-01-01T00:00:00", "valid_until": "2024-01-01T00:00:01", "is_active": False}).json()
        res = client.put(f"/api/coupons/{created['id']}", json={"code": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/coupons", json={"code": "test", "discount_type": "Percent", "discount_value": 1, "min_order_value": 0.0, "max_uses": None, "uses_count": 0, "valid_from": "2024-01-01T00:00:00", "valid_until": "2024-01-01T00:00:01", "is_active": False}).json()
        res = client.delete(f"/api/coupons/{created['id']}")
        assert res.status_code == 204

    def test_create_fails_when_valid_until_after_valid_from_violated(self, client: TestClient):
        # Simple rule violated → 422
        data = {"code": "test", "discount_type": "Percent", "discount_value": 1, "min_order_value": 0.0, "uses_count": 0, "valid_from": 1, "valid_until": 0, "is_active": False, "max_uses": 0}
        res = client.post("/api/coupons", json=data)
        assert res.status_code == 422

    def test_create_fails_when_discount_value_positive_violated(self, client: TestClient):
        # Simple rule violated → 422
        data = {"code": "test", "discount_type": "Percent", "discount_value": 0, "min_order_value": 0.0, "uses_count": 0, "valid_from": "2024-01-01T00:00:00", "valid_until": "2024-01-01T00:00:01", "is_active": False, "max_uses": 0}
        res = client.post("/api/coupons", json=data)
        assert res.status_code == 422

    def test_create_fails_when_percent_discount_range_violated(self, client: TestClient):
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"code": "test", "discount_type": "Percent", "discount_value": 101, "min_order_value": 0.0, "uses_count": 0, "valid_from": "2024-01-01T00:00:00", "valid_until": "2024-01-01T00:00:01", "is_active": False, "max_uses": None}
        res = client.post("/api/coupons", json=data)
        assert res.status_code == 422

    def test_create_fails_when_uses_not_exceed_max_violated(self, client: TestClient):
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"code": "test", "discount_type": "Percent", "discount_value": 1, "min_order_value": 0.0, "uses_count": 99999, "valid_from": "2024-01-01T00:00:00", "valid_until": "2024-01-01T00:00:01", "is_active": False, "max_uses": 1}
        res = client.post("/api/coupons", json=data)
        assert res.status_code == 422


class TestTradeListing:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/trade_listings")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        data = {"listing_type": "FixedPrice", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}
        res = client.post("/api/trade_listings", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        res = client.get(f"/api/trade_listings/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        res = client.put(f"/api/trade_listings/{created['id']}", json={"asking_price": 0.0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        res = client.delete(f"/api/trade_listings/{created['id']}")
        assert res.status_code == 204

    def test_create_fails_when_fixed_price_requires_asking_price_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": None, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}
        res = client.post("/api/trade_listings", json=data)
        assert res.status_code == 422

    def test_create_fails_when_auction_requires_start_price_and_end_time_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"listing_type": "Auction", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": None, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}
        res = client.post("/api/trade_listings", json=data)
        assert res.status_code == 422

    def test_create_fails_when_quantity_positive_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        # Simple rule violated → 422
        data = {"listing_type": "Auction", "foil": False, "condition": "Mint", "quantity": 10000, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}
        res = client.post("/api/trade_listings", json=data)
        assert res.status_code == 422


class TestTradeBid:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/trade_bids")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_trade_listing = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        data = {"amount": 1, "placed_at": "2024-01-01T00:00:00", "is_winning": False, "listing_id": _dep_trade_listing["id"], "bidder_id": _dep_player["id"]}
        res = client.post("/api/trade_bids", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_trade_listing = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        created = client.post("/api/trade_bids", json={"amount": 1, "placed_at": "2024-01-01T00:00:00", "is_winning": False, "listing_id": _dep_trade_listing["id"], "bidder_id": _dep_player["id"]}).json()
        res = client.get(f"/api/trade_bids/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_trade_listing = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        created = client.post("/api/trade_bids", json={"amount": 1, "placed_at": "2024-01-01T00:00:00", "is_winning": False, "listing_id": _dep_trade_listing["id"], "bidder_id": _dep_player["id"]}).json()
        res = client.put(f"/api/trade_bids/{created['id']}", json={"amount": 1})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_trade_listing = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        created = client.post("/api/trade_bids", json={"amount": 1, "placed_at": "2024-01-01T00:00:00", "is_winning": False, "listing_id": _dep_trade_listing["id"], "bidder_id": _dep_player["id"]}).json()
        res = client.delete(f"/api/trade_bids/{created['id']}")
        assert res.status_code == 204

    def test_create_fails_when_amount_positive_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_trade_listing = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        # Simple rule violated → 422
        data = {"amount": 0, "placed_at": "2024-01-01T00:00:00", "is_winning": False, "listing_id": _dep_trade_listing["id"], "bidder_id": _dep_player["id"]}
        res = client.post("/api/trade_bids", json=data)
        assert res.status_code == 422


class TestTradeTransaction:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/trade_transactions")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_trade_listing = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        data = {"final_price": 1, "platform_fee": 1.0, "status": "Pending", "completed_at": "2024-01-01T00:00:00", "listing_id": _dep_trade_listing["id"], "buyer_id": _dep_player["id"], "seller_id": _dep_player["id"]}
        res = client.post("/api/trade_transactions", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_trade_listing = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        created = client.post("/api/trade_transactions", json={"final_price": 1, "platform_fee": 1.0, "status": "Pending", "completed_at": "2024-01-01T00:00:00", "listing_id": _dep_trade_listing["id"], "buyer_id": _dep_player["id"], "seller_id": _dep_player["id"]}).json()
        res = client.get(f"/api/trade_transactions/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_trade_listing = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        created = client.post("/api/trade_transactions", json={"final_price": 1, "platform_fee": 1.0, "status": "Pending", "completed_at": "2024-01-01T00:00:00", "listing_id": _dep_trade_listing["id"], "buyer_id": _dep_player["id"], "seller_id": _dep_player["id"]}).json()
        res = client.put(f"/api/trade_transactions/{created['id']}", json={"final_price": 1})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_trade_listing = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        created = client.post("/api/trade_transactions", json={"final_price": 1, "platform_fee": 1.0, "status": "Pending", "completed_at": "2024-01-01T00:00:00", "listing_id": _dep_trade_listing["id"], "buyer_id": _dep_player["id"], "seller_id": _dep_player["id"]}).json()
        res = client.delete(f"/api/trade_transactions/{created['id']}")
        assert res.status_code == 204

    def test_create_fails_when_fee_not_exceed_price_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_trade_listing = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        # Simple rule violated → 422
        data = {"final_price": 1, "platform_fee": 99999, "status": "Completed", "completed_at": "2024-01-01T00:00:00", "listing_id": _dep_trade_listing["id"], "buyer_id": _dep_player["id"], "seller_id": _dep_player["id"]}
        res = client.post("/api/trade_transactions", json=data)
        assert res.status_code == 422

    def test_create_fails_when_fee_not_negative_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_trade_listing = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        # Simple rule violated → 422
        data = {"final_price": 1, "platform_fee": -1, "status": "Completed", "completed_at": "2024-01-01T00:00:00", "listing_id": _dep_trade_listing["id"], "buyer_id": _dep_player["id"], "seller_id": _dep_player["id"]}
        res = client.post("/api/trade_transactions", json=data)
        assert res.status_code == 422

    def test_create_fails_when_final_price_positive_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_trade_listing = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        # Simple rule violated → 422
        data = {"final_price": 0, "platform_fee": 1.0, "status": "Completed", "completed_at": "2024-01-01T00:00:00", "listing_id": _dep_trade_listing["id"], "buyer_id": _dep_player["id"], "seller_id": _dep_player["id"]}
        res = client.post("/api/trade_transactions", json=data)
        assert res.status_code == 422

    def test_create_fails_when_completed_requires_completed_at_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_trade_listing = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"final_price": 1, "platform_fee": 1.0, "status": "Completed", "completed_at": None, "listing_id": _dep_trade_listing["id"], "buyer_id": _dep_player["id"], "seller_id": _dep_player["id"]}
        res = client.post("/api/trade_transactions", json=data)
        assert res.status_code == 422


class TestCardPriceHistory:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/card_price_histories")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        data = {"price_date": "2024-01-01", "avg_price": 0.0, "min_price": 0.0, "max_price": 0.0, "volume": 0, "foil": False, "card_id": _dep_card["id"]}
        res = client.post("/api/card_price_histories", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/card_price_histories", json={"price_date": "2024-01-01", "avg_price": 0.0, "min_price": 0.0, "max_price": 0.0, "volume": 0, "foil": False, "card_id": _dep_card["id"]}).json()
        res = client.get(f"/api/card_price_histories/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/card_price_histories", json={"price_date": "2024-01-01", "avg_price": 0.0, "min_price": 0.0, "max_price": 0.0, "volume": 0, "foil": False, "card_id": _dep_card["id"]}).json()
        res = client.put(f"/api/card_price_histories/{created['id']}", json={"price_date": "2024-01-01"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        created = client.post("/api/card_price_histories", json={"price_date": "2024-01-01", "avg_price": 0.0, "min_price": 0.0, "max_price": 0.0, "volume": 0, "foil": False, "card_id": _dep_card["id"]}).json()
        res = client.delete(f"/api/card_price_histories/{created['id']}")
        assert res.status_code == 204

    def test_create_fails_when_price_bounds_consistent_violated(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        # Simple rule violated → 422
        data = {"price_date": "2024-01-01", "avg_price": 1, "min_price": 99999, "max_price": 0.0, "volume": 0, "foil": False, "card_id": _dep_card["id"]}
        res = client.post("/api/card_price_histories", json=data)
        assert res.status_code == 422

    def test_create_fails_when_volume_not_negative_violated(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        # Simple rule violated → 422
        data = {"price_date": "2024-01-01", "avg_price": 0.0, "min_price": 0.0, "max_price": 0.0, "volume": -1, "foil": False, "card_id": _dep_card["id"]}
        res = client.post("/api/card_price_histories", json=data)
        assert res.status_code == 422

    def test_create_fails_when_prices_not_negative_violated(self, client: TestClient):
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        # Simple rule violated → 422
        data = {"price_date": "2024-01-01", "avg_price": 0.0, "min_price": -1, "max_price": 0.0, "volume": 0, "foil": False, "card_id": _dep_card["id"]}
        res = client.post("/api/card_price_histories", json=data)
        assert res.status_code == 422


class TestTradeDispute:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/trade_disputes")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_trade_listing = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        _dep_trade_transaction = client.post("/api/trade_transactions", json={"final_price": 1, "platform_fee": 1.0, "status": "Pending", "completed_at": "2024-01-01T00:00:00", "listing_id": _dep_trade_listing["id"], "buyer_id": _dep_player["id"], "seller_id": _dep_player["id"]}).json()
        data = {"reason": "ItemNotReceived", "description": "test", "status": "Resolved", "opened_at": "2024-01-01T00:00:00", "resolved_at": None, "transaction_id": _dep_trade_transaction["id"], "opened_by_id": _dep_player["id"]}
        res = client.post("/api/trade_disputes", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_trade_listing = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        _dep_trade_transaction = client.post("/api/trade_transactions", json={"final_price": 1, "platform_fee": 1.0, "status": "Pending", "completed_at": "2024-01-01T00:00:00", "listing_id": _dep_trade_listing["id"], "buyer_id": _dep_player["id"], "seller_id": _dep_player["id"]}).json()
        created = client.post("/api/trade_disputes", json={"reason": "ItemNotReceived", "description": "test", "status": "Resolved", "opened_at": "2024-01-01T00:00:00", "resolved_at": None, "transaction_id": _dep_trade_transaction["id"], "opened_by_id": _dep_player["id"]}).json()
        res = client.get(f"/api/trade_disputes/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_trade_listing = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        _dep_trade_transaction = client.post("/api/trade_transactions", json={"final_price": 1, "platform_fee": 1.0, "status": "Pending", "completed_at": "2024-01-01T00:00:00", "listing_id": _dep_trade_listing["id"], "buyer_id": _dep_player["id"], "seller_id": _dep_player["id"]}).json()
        created = client.post("/api/trade_disputes", json={"reason": "ItemNotReceived", "description": "test", "status": "Resolved", "opened_at": "2024-01-01T00:00:00", "resolved_at": None, "transaction_id": _dep_trade_transaction["id"], "opened_by_id": _dep_player["id"]}).json()
        res = client.put(f"/api/trade_disputes/{created['id']}", json={"description": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_trade_listing = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        _dep_trade_transaction = client.post("/api/trade_transactions", json={"final_price": 1, "platform_fee": 1.0, "status": "Pending", "completed_at": "2024-01-01T00:00:00", "listing_id": _dep_trade_listing["id"], "buyer_id": _dep_player["id"], "seller_id": _dep_player["id"]}).json()
        created = client.post("/api/trade_disputes", json={"reason": "ItemNotReceived", "description": "test", "status": "Resolved", "opened_at": "2024-01-01T00:00:00", "resolved_at": None, "transaction_id": _dep_trade_transaction["id"], "opened_by_id": _dep_player["id"]}).json()
        res = client.delete(f"/api/trade_disputes/{created['id']}")
        assert res.status_code == 204

    def test_create_fails_when_resolved_at_requires_terminal_status_violated(self, client: TestClient):
        _dep_player = client.post("/api/players", json={"display_name": "test", "rank": "Bronze", "rating": 0, "peak_rating": 1000, "is_verified": False, "created_at": "2024-01-01T00:00:00"}).json()
        _dep_card_set = client.post("/api/card_sets", json={"name": "test", "code": "test", "release_date": "2024-01-01", "set_type": "Core", "total_cards": 1, "is_rotated": False, "rotation_date": None}).json()
        _dep_card = client.post("/api/cards", json={"name": "test", "card_type": "Creature", "rarity": "Common", "mana_cost": 0, "mana_colors": "White", "description": "test", "legal_formats": "Standard", "is_banned": False, "is_restricted": False, "power_level": 1, "attack": 0, "defense": 0, "loyalty": None, "set_id": _dep_card_set["id"]}).json()
        _dep_trade_listing = client.post("/api/trade_listings", json={"listing_type": "FixedPrice", "foil": False, "condition": "Mint", "quantity": 1, "status": "Active", "created_at": "2024-01-01T00:00:00", "asking_price": 0.0, "auction_start_price": 0.0, "auction_end_time": "2024-01-01T00:00:00", "seller_id": _dep_player["id"], "card_id": _dep_card["id"]}).json()
        _dep_trade_transaction = client.post("/api/trade_transactions", json={"final_price": 1, "platform_fee": 1.0, "status": "Pending", "completed_at": "2024-01-01T00:00:00", "listing_id": _dep_trade_listing["id"], "buyer_id": _dep_player["id"], "seller_id": _dep_player["id"]}).json()
        # IMPLIES: antecedent=true, consequent violated → 422
        data = {"reason": "ItemNotReceived", "description": "test", "status": "Open", "opened_at": "2024-01-01T00:00:00", "resolved_at": "2024-01-01T00:00:00", "transaction_id": _dep_trade_transaction["id"], "opened_by_id": _dep_player["id"]}
        res = client.post("/api/trade_disputes", json=data)
        assert res.status_code == 422
