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


class TestProduct:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/products")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"name": "test", "product_type": "test", "price": 0.0, "stock": 0, "active": False, "discount_percent": 0, "featured": False}
        res = client.post("/api/products", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/products", json={"name": "test", "product_type": "test", "price": 0.0, "stock": 0, "active": False, "discount_percent": 0, "featured": False}).json()
        res = client.get(f"/api/products/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/products", json={"name": "test", "product_type": "test", "price": 0.0, "stock": 0, "active": False, "discount_percent": 0, "featured": False}).json()
        res = client.put(f"/api/products/{created['id']}", json={"name": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/products", json={"name": "test", "product_type": "test", "price": 0.0, "stock": 0, "active": False, "discount_percent": 0, "featured": False}).json()
        res = client.delete(f"/api/products/{created['id']}")
        assert res.status_code == 204


class TestOrder:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/orders")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"status": "test", "total": 0.0, "discount_applied": 0.0, "currency": "test", "created_at": datetime(2024, 1, 1, 0, 0, 0)}
        res = client.post("/api/orders", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/orders", json={"status": "test", "total": 0.0, "discount_applied": 0.0, "currency": "test", "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.get(f"/api/orders/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/orders", json={"status": "test", "total": 0.0, "discount_applied": 0.0, "currency": "test", "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.put(f"/api/orders/{created['id']}", json={"status": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/orders", json={"status": "test", "total": 0.0, "discount_applied": 0.0, "currency": "test", "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.delete(f"/api/orders/{created['id']}")
        assert res.status_code == 204


class TestOrderItem:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/order_items")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"quantity": 0, "price_at_purchase": 0.0, "foil": False}
        res = client.post("/api/order_items", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/order_items", json={"quantity": 0, "price_at_purchase": 0.0, "foil": False}).json()
        res = client.get(f"/api/order_items/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/order_items", json={"quantity": 0, "price_at_purchase": 0.0, "foil": False}).json()
        res = client.put(f"/api/order_items/{created['id']}", json={"quantity": 0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/order_items", json={"quantity": 0, "price_at_purchase": 0.0, "foil": False}).json()
        res = client.delete(f"/api/order_items/{created['id']}")
        assert res.status_code == 204


class TestCoupon:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/coupons")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"code": "test", "discount_type": "test", "discount_value": 0.0, "min_order_value": 0.0, "uses_count": 0, "valid_from": datetime(2024, 1, 1, 0, 0, 0), "valid_until": datetime(2024, 1, 1, 0, 0, 0), "is_active": False}
        res = client.post("/api/coupons", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/coupons", json={"code": "test", "discount_type": "test", "discount_value": 0.0, "min_order_value": 0.0, "uses_count": 0, "valid_from": datetime(2024, 1, 1, 0, 0, 0), "valid_until": datetime(2024, 1, 1, 0, 0, 0), "is_active": False}).json()
        res = client.get(f"/api/coupons/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/coupons", json={"code": "test", "discount_type": "test", "discount_value": 0.0, "min_order_value": 0.0, "uses_count": 0, "valid_from": datetime(2024, 1, 1, 0, 0, 0), "valid_until": datetime(2024, 1, 1, 0, 0, 0), "is_active": False}).json()
        res = client.put(f"/api/coupons/{created['id']}", json={"code": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/coupons", json={"code": "test", "discount_type": "test", "discount_value": 0.0, "min_order_value": 0.0, "uses_count": 0, "valid_from": datetime(2024, 1, 1, 0, 0, 0), "valid_until": datetime(2024, 1, 1, 0, 0, 0), "is_active": False}).json()
        res = client.delete(f"/api/coupons/{created['id']}")
        assert res.status_code == 204


class TestTradelisting:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/tradelistings")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"listing_type": "test", "foil": False, "condition": "test", "quantity": 0, "status": "test", "created_at": datetime(2024, 1, 1, 0, 0, 0)}
        res = client.post("/api/tradelistings", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/tradelistings", json={"listing_type": "test", "foil": False, "condition": "test", "quantity": 0, "status": "test", "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.get(f"/api/tradelistings/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/tradelistings", json={"listing_type": "test", "foil": False, "condition": "test", "quantity": 0, "status": "test", "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.put(f"/api/tradelistings/{created['id']}", json={"listing_type": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/tradelistings", json={"listing_type": "test", "foil": False, "condition": "test", "quantity": 0, "status": "test", "created_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.delete(f"/api/tradelistings/{created['id']}")
        assert res.status_code == 204


class TestTradeBid:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/trade_bids")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"amount": 0.0, "placed_at": datetime(2024, 1, 1, 0, 0, 0), "is_winning": False}
        res = client.post("/api/trade_bids", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/trade_bids", json={"amount": 0.0, "placed_at": datetime(2024, 1, 1, 0, 0, 0), "is_winning": False}).json()
        res = client.get(f"/api/trade_bids/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/trade_bids", json={"amount": 0.0, "placed_at": datetime(2024, 1, 1, 0, 0, 0), "is_winning": False}).json()
        res = client.put(f"/api/trade_bids/{created['id']}", json={"amount": 0.0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/trade_bids", json={"amount": 0.0, "placed_at": datetime(2024, 1, 1, 0, 0, 0), "is_winning": False}).json()
        res = client.delete(f"/api/trade_bids/{created['id']}")
        assert res.status_code == 204


class TestTradeTransaction:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/trade_transactions")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"final_price": 0.0, "platform_fee": 0.0, "status": "test"}
        res = client.post("/api/trade_transactions", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/trade_transactions", json={"final_price": 0.0, "platform_fee": 0.0, "status": "test"}).json()
        res = client.get(f"/api/trade_transactions/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/trade_transactions", json={"final_price": 0.0, "platform_fee": 0.0, "status": "test"}).json()
        res = client.put(f"/api/trade_transactions/{created['id']}", json={"final_price": 0.0})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/trade_transactions", json={"final_price": 0.0, "platform_fee": 0.0, "status": "test"}).json()
        res = client.delete(f"/api/trade_transactions/{created['id']}")
        assert res.status_code == 204


class TestCardPriceHistory:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/card_price_histories")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"price_date": date(2024, 1, 1), "avg_price": 0.0, "min_price": 0.0, "max_price": 0.0, "volume": 0, "foil": False}
        res = client.post("/api/card_price_histories", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/card_price_histories", json={"price_date": date(2024, 1, 1), "avg_price": 0.0, "min_price": 0.0, "max_price": 0.0, "volume": 0, "foil": False}).json()
        res = client.get(f"/api/card_price_histories/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/card_price_histories", json={"price_date": date(2024, 1, 1), "avg_price": 0.0, "min_price": 0.0, "max_price": 0.0, "volume": 0, "foil": False}).json()
        res = client.put(f"/api/card_price_histories/{created['id']}", json={"price_date": date(2024, 1, 1)})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/card_price_histories", json={"price_date": date(2024, 1, 1), "avg_price": 0.0, "min_price": 0.0, "max_price": 0.0, "volume": 0, "foil": False}).json()
        res = client.delete(f"/api/card_price_histories/{created['id']}")
        assert res.status_code == 204


class TestTradeDispute:
    def test_list_returns_200(self, client: TestClient):
        res = client.get("/api/trade_disputes")
        assert res.status_code == 200
        assert isinstance(res.json(), list)

    def test_create_returns_201(self, client: TestClient):
        data = {"reason": "test", "description": "test", "status": "test", "opened_at": datetime(2024, 1, 1, 0, 0, 0)}
        res = client.post("/api/trade_disputes", json=data)
        assert res.status_code == 201
        assert "id" in res.json()

    def test_retrieve_returns_200(self, client: TestClient):
        created = client.post("/api/trade_disputes", json={"reason": "test", "description": "test", "status": "test", "opened_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.get(f"/api/trade_disputes/{created['id']}")
        assert res.status_code == 200

    def test_update_returns_200(self, client: TestClient):
        created = client.post("/api/trade_disputes", json={"reason": "test", "description": "test", "status": "test", "opened_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.put(f"/api/trade_disputes/{created['id']}", json={"reason": "test"})
        assert res.status_code == 200

    def test_delete_returns_204(self, client: TestClient):
        created = client.post("/api/trade_disputes", json={"reason": "test", "description": "test", "status": "test", "opened_at": datetime(2024, 1, 1, 0, 0, 0)}).json()
        res = client.delete(f"/api/trade_disputes/{created['id']}")
        assert res.status_code == 204
