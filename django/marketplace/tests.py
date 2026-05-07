from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from .models import Product, Order, OrderItem, Coupon, Tradelisting, TradeBid, TradeTransaction, CardPriceHistory, TradeDispute


class ProductAPITest(APITestCase):
    def setUp(self):
        # TODO: create related Card (cross-app dependency)
        # TODO: create related CardSet (cross-app dependency)
        self.obj = Product.objects.create(
            name="test",
            price="0.00",
            description="test",
            image_url="https://example.com",
        )
        self.list_url = reverse("product-list")
        self.detail_url = reverse("product-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"name": "test", "product_type": "test", "price": "0.00", "stock": 0, "active": False, "discount_percent": 0, "featured": False}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"name": "test"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class OrderAPITest(APITestCase):
    def setUp(self):
        self.order_item = OrderItem.objects.create()
        self.coupon = Coupon.objects.create()
        # TODO: create related Player (cross-app dependency)
        self.obj = Order.objects.create(
            items=self.order_item,
            coupon=self.coupon,
            payment_method="test",
            payment_reference="test",
            shipping_address="test",
            tracking_number="test",
            created_at="2024-01-01T00:00:00Z",
            paid_at="2024-01-01T00:00:00Z",
            shipped_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("order-list")
        self.detail_url = reverse("order-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"status": "test", "total": "0.00", "discount_applied": "0.00", "currency": "test", "created_at": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"status": "test"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class OrderItemAPITest(APITestCase):
    def setUp(self):
        self.order = Order.objects.create()
        self.product = Product.objects.create()
        self.obj = OrderItem.objects.create(
            order=self.order,
            product=self.product,
            quantity=0,
            price_at_purchase="0.00",
        )
        self.list_url = reverse("order_item-list")
        self.detail_url = reverse("order_item-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"quantity": 0, "price_at_purchase": "0.00", "foil": False}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"quantity": 0}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class CouponAPITest(APITestCase):
    def setUp(self):
        self.obj = Coupon.objects.create(
            code="test",
            discount_value="0.00",
            max_uses=0,
            valid_from="2024-01-01T00:00:00Z",
            valid_until="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("coupon-list")
        self.detail_url = reverse("coupon-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"code": "test", "discount_type": "test", "discount_value": "0.00", "min_order_value": "0.00", "uses_count": 0, "valid_from": "2024-01-01T00:00:00Z", "valid_until": "2024-01-01T00:00:00Z", "is_active": False}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"code": "test"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class TradelistingAPITest(APITestCase):
    def setUp(self):
        self.trade_bid = TradeBid.objects.create()
        # TODO: create related Player (cross-app dependency)
        # TODO: create related Card (cross-app dependency)
        self.obj = Tradelisting.objects.create(
            bids=self.trade_bid,
            asking_price="0.00",
            auction_start_price="0.00",
            auction_current_bid="0.00",
            auction_end_time="2024-01-01T00:00:00Z",
            description="test",
            created_at="2024-01-01T00:00:00Z",
            expires_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("tradelisting-list")
        self.detail_url = reverse("tradelisting-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"listing_type": "test", "foil": False, "condition": "test", "quantity": 0, "status": "test", "created_at": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"listing_type": "test"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class TradeBidAPITest(APITestCase):
    def setUp(self):
        self.trade_listing = TradeListing.objects.create()
        # TODO: create related Player (cross-app dependency)
        self.obj = TradeBid.objects.create(
            listing=self.trade_listing,
            amount="0.00",
            placed_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("trade_bid-list")
        self.detail_url = reverse("trade_bid-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"amount": "0.00", "placed_at": "2024-01-01T00:00:00Z", "is_winning": False}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"amount": "0.00"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class TradeTransactionAPITest(APITestCase):
    def setUp(self):
        self.trade_listing = TradeListing.objects.create()
        # TODO: create related Player (cross-app dependency)
        # TODO: create related Player (cross-app dependency)
        self.obj = TradeTransaction.objects.create(
            listing=self.trade_listing,
            final_price="0.00",
            platform_fee="0.00",
            completed_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("trade_transaction-list")
        self.detail_url = reverse("trade_transaction-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"final_price": "0.00", "platform_fee": "0.00", "status": "test"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"final_price": "0.00"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class CardPriceHistoryAPITest(APITestCase):
    def setUp(self):
        # TODO: create related Card (cross-app dependency)
        self.obj = CardPriceHistory.objects.create(
            price_date="2024-01-01",
            avg_price="0.00",
            min_price="0.00",
            max_price="0.00",
            volume=0,
        )
        self.list_url = reverse("card_price_history-list")
        self.detail_url = reverse("card_price_history-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"price_date": "2024-01-01", "avg_price": "0.00", "min_price": "0.00", "max_price": "0.00", "volume": 0, "foil": False}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"price_date": "2024-01-01"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class TradeDisputeAPITest(APITestCase):
    def setUp(self):
        self.trade_transaction = TradeTransaction.objects.create()
        # TODO: create related Player (cross-app dependency)
        # TODO: create related Player (cross-app dependency)
        self.obj = TradeDispute.objects.create(
            transaction=self.trade_transaction,
            reason="test",
            description="test",
            resolution="test",
            opened_at="2024-01-01T00:00:00Z",
            resolved_at="2024-01-01T00:00:00Z",
        )
        self.list_url = reverse("trade_dispute-list")
        self.detail_url = reverse("trade_dispute-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {"reason": "test", "description": "test", "status": "test", "opened_at": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"reason": "test"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)
