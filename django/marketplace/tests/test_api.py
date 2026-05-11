from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from ..models import Product, Order, OrderItem, Coupon, Tradelisting, TradeBid, TradeTransaction, CardPriceHistory, TradeDispute


class ProductAPITest(APITestCase):
    def setUp(self):
        self.obj = Product.objects.create(name="test", price="0.00")
        self.list_url = reverse("product-list")
        self.detail_url = reverse("product-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "name": "test",
            "product_type": "SingleCard",
            "price": "0.00",
            "stock": 0,
            "active": False,
            "discount_percent": 0,
            "featured": False
        }
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
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        self.player = _dep_player
        self.obj = Order.objects.create(player=_dep_player, created_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("order-list")
        self.detail_url = reverse("order-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "status": "Pending",
            "total": "0.00",
            "discount_applied": "0.00",
            "currency": "xxx",
            "created_at": "2024-01-01T00:00:00Z",
            "player": self.player.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"total": "0.00"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class OrderItemAPITest(APITestCase):
    def setUp(self):
        _dep_product = Product.objects.create(name="test", price="0.00")
        self.product = _dep_product
        self.obj = OrderItem.objects.create(product=_dep_product, quantity=0, price_at_purchase="0.00")
        self.list_url = reverse("order_item-list")
        self.detail_url = reverse("order_item-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "quantity": 0,
            "price_at_purchase": "0.00",
            "foil": False,
            "product": self.product.pk
        }
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
        self.obj = Coupon.objects.create(code="test", discount_value="0.00", valid_from="2024-01-01T00:00:00Z", valid_until="2024-01-01T00:00:00Z")
        self.list_url = reverse("coupon-list")
        self.detail_url = reverse("coupon-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "code": "test",
            "discount_type": "Percent",
            "discount_value": "0.00",
            "min_order_value": "0.00",
            "uses_count": 0,
            "valid_from": "2024-01-01T00:00:00Z",
            "valid_until": "2024-01-01T00:00:00Z",
            "is_active": False
        }
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
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        self.player = _dep_player
        self.cardset = _dep_card_set
        self.card = _dep_card
        self.obj = Tradelisting.objects.create(seller=_dep_player, card=_dep_card, created_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("tradelisting-list")
        self.detail_url = reverse("tradelisting-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "listing_type": "FixedPrice",
            "foil": False,
            "condition": "Mint",
            "quantity": 0,
            "status": "Active",
            "created_at": "2024-01-01T00:00:00Z",
            "seller": self.player.pk,
            "card": self.card.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"asking_price": "0.00"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)


class TradeBidAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        _dep_tradelisting = Tradelisting.objects.create(created_at="2024-01-01T00:00:00Z", seller=_dep_player, card=_dep_card)
        self.player = _dep_player
        self.cardset = _dep_card_set
        self.card = _dep_card
        self.tradelisting = _dep_tradelisting
        self.obj = TradeBid.objects.create(listing=_dep_tradelisting, bidder=_dep_player, amount="0.00", placed_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("trade_bid-list")
        self.detail_url = reverse("trade_bid-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "amount": "0.00",
            "placed_at": "2024-01-01T00:00:00Z",
            "is_winning": False,
            "listing": self.tradelisting.pk,
            "bidder": self.player.pk
        }
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
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        _dep_tradelisting = Tradelisting.objects.create(created_at="2024-01-01T00:00:00Z", seller=_dep_player, card=_dep_card)
        self.player = _dep_player
        self.cardset = _dep_card_set
        self.card = _dep_card
        self.tradelisting = _dep_tradelisting
        self.obj = TradeTransaction.objects.create(listing=_dep_tradelisting, buyer=_dep_player, seller=_dep_player, final_price="0.00", platform_fee="0.00")
        self.list_url = reverse("trade_transaction-list")
        self.detail_url = reverse("trade_transaction-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        _fresh_tradelisting = Tradelisting.objects.create(seller=_dep_player, card=_dep_card, created_at="2024-01-01T00:00:00Z")
        data = {
            "final_price": "0.00",
            "platform_fee": "0.00",
            "status": "Pending",
            "listing": _fresh_tradelisting.pk,
            "buyer": self.player.pk,
            "seller": self.player.pk
        }
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
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        self.cardset = _dep_card_set
        self.card = _dep_card
        self.obj = CardPriceHistory.objects.create(card=_dep_card, price_date="2024-01-01", avg_price="0.00", min_price="0.00", max_price="0.00", volume=0)
        self.list_url = reverse("card_price_history-list")
        self.detail_url = reverse("card_price_history-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "price_date": "2024-01-01",
            "avg_price": "0.00",
            "min_price": "0.00",
            "max_price": "0.00",
            "volume": 0,
            "foil": False,
            "card": self.card.pk
        }
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
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        _dep_tradelisting = Tradelisting.objects.create(created_at="2024-01-01T00:00:00Z", seller=_dep_player, card=_dep_card)
        _dep_trade_transaction = TradeTransaction.objects.create(final_price="0.00", platform_fee="0.00", listing=_dep_tradelisting, buyer=_dep_player, seller=_dep_player)
        self.player = _dep_player
        self.cardset = _dep_card_set
        self.card = _dep_card
        self.tradelisting = _dep_tradelisting
        self.tradetransaction = _dep_trade_transaction
        self.obj = TradeDispute.objects.create(transaction=_dep_trade_transaction, opened_by=_dep_player, reason="ItemNotReceived", description="test", opened_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("trade_dispute-list")
        self.detail_url = reverse("trade_dispute-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        _dep_tradelisting = Tradelisting.objects.create(created_at="2024-01-01T00:00:00Z", seller=_dep_player, card=_dep_card)
        _fresh_trade_transaction = TradeTransaction.objects.create(listing=_dep_tradelisting, buyer=_dep_player, seller=_dep_player, final_price="0.00", platform_fee="0.00")
        data = {
            "reason": "ItemNotReceived",
            "description": "test",
            "status": "Open",
            "opened_at": "2024-01-01T00:00:00Z",
            "transaction": _fresh_trade_transaction.pk,
            "opened_by": self.player.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"description": "test"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)
