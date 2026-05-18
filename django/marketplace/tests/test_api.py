from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from ..models import Product, Order, OrderItem, Coupon, TradeListing, TradeBid, TradeTransaction, CardPriceHistory, TradeDispute


class ProductAPITest(APITestCase):
    def setUp(self):
        self.obj = Product.objects.create(name="test", price=1, stock=0)
        self.list_url = reverse("product-list")
        self.detail_url = reverse("product-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "name": "test",
            "price": 1,
            "stock": 0
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

    def test_create_fails_when_price_positive_violated(self):
        # Simple rule violated → 400
        data = {"name": "test", "price": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_stock_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"name": "test", "price": "0.00", "stock": -1}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_discount_percent_range_violated(self):
        # Simple rule violated → 400
        data = {"name": "test", "price": "0.00", "discount_percent": 101}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class OrderAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        self.player = _dep_player
        self.obj = Order.objects.create(player=_dep_player, total=0, discount_applied="0.00", tracking_number="test", created_at="2024-01-01T00:00:00Z", paid_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("order-list")
        self.detail_url = reverse("order-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "total": 0,
            "discount_applied": "0.00",
            "tracking_number": "test",
            "created_at": "2024-01-01T00:00:00Z",
            "paid_at": "2024-01-01T00:00:00Z",
            "player": self.player.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"total": 0}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

    def test_create_fails_when_paid_requires_paid_at_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"created_at": "2024-01-01T00:00:00Z", "player": self.player.pk, "status": "Paid", "paid_at": None}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_shipped_requires_tracking_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"created_at": "2024-01-01T00:00:00Z", "player": self.player.pk, "status": "Shipped", "tracking_number": None}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_shipped_at_requires_shipped_status_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"created_at": "2024-01-01T00:00:00Z", "player": self.player.pk, "shipped_at": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_total_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"created_at": "2024-01-01T00:00:00Z", "player": self.player.pk, "status": "Shipped", "paid_at": "2024-01-01T00:00:00Z", "tracking_number": "test", "shipped_at": "2024-01-01T00:00:00Z", "total": -1}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class OrderItemAPITest(APITestCase):
    def setUp(self):
        _dep_product = Product.objects.create(name="test", price=1)
        self.product = _dep_product
        self.obj = OrderItem.objects.create(product=_dep_product, quantity=1, price_at_purchase=0)
        self.list_url = reverse("order_item-list")
        self.detail_url = reverse("order_item-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "quantity": 1,
            "price_at_purchase": 0,
            "product": self.product.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"quantity": 1}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

    def test_create_fails_when_quantity_positive_violated(self):
        # Simple rule violated → 400
        data = {"quantity": 0, "price_at_purchase": "0.00", "product": self.product.pk}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_price_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"quantity": 0, "price_at_purchase": -1, "product": self.product.pk}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class CouponAPITest(APITestCase):
    def setUp(self):
        self.obj = Coupon.objects.create(code="test", discount_value=1, uses_count=0, valid_from="2024-01-01T00:00:00Z", valid_until="2024-01-01T00:00:01Z")
        self.list_url = reverse("coupon-list")
        self.detail_url = reverse("coupon-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "code": "test",
            "discount_value": 1,
            "uses_count": 0,
            "valid_from": "2024-01-01T00:00:00Z",
            "valid_until": "2024-01-01T00:00:01Z"
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

    def test_create_fails_when_discount_value_positive_violated(self):
        # Simple rule violated → 400
        data = {"code": "test", "discount_value": 0, "valid_from": "2024-01-01T00:00:00Z", "valid_until": "2024-01-01T00:00:00Z", "discount_type": "Percent", "max_uses": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_percent_discount_range_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"code": "test", "discount_value": 101, "valid_from": "2024-01-01T00:00:00Z", "valid_until": "2024-01-01T00:00:00Z", "discount_type": "Percent"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_uses_not_exceed_max_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"code": "test", "discount_value": "0.00", "valid_from": "2024-01-01T00:00:00Z", "valid_until": "2024-01-01T00:00:00Z", "max_uses": 0}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class TradeListingAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=1)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        self.player = _dep_player
        self.cardset = _dep_card_set
        self.card = _dep_card
        self.obj = TradeListing.objects.create(seller=_dep_player, card=_dep_card, asking_price="0.00", auction_start_price="0.00", auction_end_time="2024-01-01T00:00:00Z", quantity=1, created_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("trade_listing-list")
        self.detail_url = reverse("trade_listing-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "asking_price": "0.00",
            "auction_start_price": "0.00",
            "auction_end_time": "2024-01-01T00:00:00Z",
            "quantity": 1,
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

    def test_create_fails_when_fixed_price_requires_asking_price_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"created_at": "2024-01-01T00:00:00Z", "seller": self.player.pk, "card": self.card.pk, "listing_type": "FixedPrice", "asking_price": None}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_auction_requires_start_price_and_end_time_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"created_at": "2024-01-01T00:00:00Z", "seller": self.player.pk, "card": self.card.pk, "listing_type": "Auction", "auction_start_price": None}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_quantity_positive_violated(self):
        # Simple rule violated → 400
        data = {"created_at": "2024-01-01T00:00:00Z", "seller": self.player.pk, "card": self.card.pk, "listing_type": "Auction", "asking_price": "0.00", "auction_start_price": "0.00", "auction_end_time": "2024-01-01T00:00:00Z", "quantity": 10000}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class TradeBidAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=1)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        _dep_trade_listing = TradeListing.objects.create(created_at="2024-01-01T00:00:00Z", seller=_dep_player, card=_dep_card)
        self.player = _dep_player
        self.cardset = _dep_card_set
        self.card = _dep_card
        self.tradelisting = _dep_trade_listing
        self.obj = TradeBid.objects.create(listing=_dep_trade_listing, bidder=_dep_player, amount=1, placed_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("trade_bid-list")
        self.detail_url = reverse("trade_bid-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "amount": 1,
            "placed_at": "2024-01-01T00:00:00Z",
            "listing": self.tradelisting.pk,
            "bidder": self.player.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"amount": 1}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

    def test_create_fails_when_amount_positive_violated(self):
        # Simple rule violated → 400
        data = {"amount": 0, "placed_at": "2024-01-01T00:00:00Z", "listing": self.tradelisting.pk, "bidder": self.player.pk}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class TradeTransactionAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=1)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        _dep_trade_listing = TradeListing.objects.create(created_at="2024-01-01T00:00:00Z", seller=_dep_player, card=_dep_card)
        self.player = _dep_player
        self.cardset = _dep_card_set
        self.card = _dep_card
        self.tradelisting = _dep_trade_listing
        self.obj = TradeTransaction.objects.create(listing=_dep_trade_listing, buyer=_dep_player, seller=_dep_player, final_price=1, platform_fee="1.00", completed_at="2024-01-01T00:00:00Z")
        self.list_url = reverse("trade_transaction-list")
        self.detail_url = reverse("trade_transaction-detail", args=[self.obj.pk])

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=1)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        _fresh_trade_listing = TradeListing.objects.create(seller=_dep_player, card=_dep_card, asking_price="0.00", auction_start_price="0.00", auction_end_time="2024-01-01T00:00:00Z", quantity=1, created_at="2024-01-01T00:00:00Z")
        data = {
            "final_price": 1,
            "platform_fee": "1.00",
            "completed_at": "2024-01-01T00:00:00Z",
            "listing": _fresh_trade_listing.pk,
            "buyer": self.player.pk,
            "seller": self.player.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_update_returns_200(self):
        res = self.client.patch(self.detail_url, {"final_price": 1}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_delete_returns_204(self):
        res = self.client.delete(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

    def test_create_fails_when_fee_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"final_price": "0.00", "platform_fee": -1, "listing": self.tradelisting.pk, "buyer": self.player.pk, "seller": self.player.pk, "status": "Completed", "completed_at": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_final_price_positive_violated(self):
        # Simple rule violated → 400
        data = {"final_price": 0, "platform_fee": "0.00", "listing": self.tradelisting.pk, "buyer": self.player.pk, "seller": self.player.pk, "status": "Completed", "completed_at": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_completed_requires_completed_at_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"final_price": "0.00", "platform_fee": "0.00", "listing": self.tradelisting.pk, "buyer": self.player.pk, "seller": self.player.pk, "status": "Completed", "completed_at": None}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class CardPriceHistoryAPITest(APITestCase):
    def setUp(self):
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=1)
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

    def test_create_fails_when_volume_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"price_date": "2024-01-01", "avg_price": "0.00", "min_price": "0.00", "max_price": "0.00", "volume": -1, "card": self.card.pk}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_prices_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"price_date": "2024-01-01", "avg_price": "0.00", "min_price": -1, "max_price": "0.00", "volume": 0, "card": self.card.pk}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class TradeDisputeAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=1)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        _dep_trade_listing = TradeListing.objects.create(created_at="2024-01-01T00:00:00Z", seller=_dep_player, card=_dep_card)
        _dep_trade_transaction = TradeTransaction.objects.create(final_price=1, platform_fee="1.00", listing=_dep_trade_listing, buyer=_dep_player, seller=_dep_player)
        self.player = _dep_player
        self.cardset = _dep_card_set
        self.card = _dep_card
        self.tradelisting = _dep_trade_listing
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
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=1)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        _dep_trade_listing = TradeListing.objects.create(created_at="2024-01-01T00:00:00Z", seller=_dep_player, card=_dep_card)
        _fresh_trade_transaction = TradeTransaction.objects.create(listing=_dep_trade_listing, buyer=_dep_player, seller=_dep_player, final_price=1, platform_fee="1.00", completed_at="2024-01-01T00:00:00Z")
        data = {
            "reason": "ItemNotReceived",
            "description": "test",
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

    def test_create_fails_when_resolved_at_requires_terminal_status_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"reason": "ItemNotReceived", "description": "test", "opened_at": "2024-01-01T00:00:00Z", "transaction": self.tradetransaction.pk, "opened_by": self.player.pk, "resolved_at": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
