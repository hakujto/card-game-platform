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

    def test_search_returns_200(self):
        res = self.client.get(self.list_url + "?q=test")
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
        res = self.client.patch(self.detail_url, {"description": "test"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

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
        from django.contrib.auth import get_user_model
        _owner_user, _ = get_user_model().objects.get_or_create(pk=_dep_player.pk, defaults={"username": f"owner_{_dep_player.pk}"})
        self.client.force_authenticate(user=_owner_user)

    def test_list_returns_200(self):
        res = self.client.get(self.list_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "total": 0,
            "discount_applied": "0.00",
            "tracking_number": "test",
            "createdAt": "2024-01-01T00:00:00Z",
            "paidAt": "2024-01-01T00:00:00Z",
            "player": self.player.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_fails_when_paid_requires_paid_at_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"createdAt": "2024-01-01T00:00:00Z", "player": self.player.pk, "status": "Paid", "paidAt": None}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_shipped_requires_tracking_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"createdAt": "2024-01-01T00:00:00Z", "player": self.player.pk, "status": "Shipped", "tracking_number": None}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_shipped_at_requires_shipped_status_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"createdAt": "2024-01-01T00:00:00Z", "player": self.player.pk, "shippedAt": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_total_not_negative_violated(self):
        # Simple rule violated → 400
        data = {"createdAt": "2024-01-01T00:00:00Z", "player": self.player.pk, "status": "Shipped", "paidAt": "2024-01-01T00:00:00Z", "tracking_number": "test", "shippedAt": "2024-01-01T00:00:00Z", "total": -1}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_transition_pending_to_paid_succeeds(self):
        self.obj.status = "Pending"
        self.obj.payment_method = "Card"  # @on: payment_method != null
        self.obj.save()
        url = reverse("order-transition-pending-to-paid", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Paid")

    def test_transition_pending_to_paid_fails_when_payment_method_missing(self):
        self.obj.status = "Pending"
        self.obj.payment_method = None
        self.obj.save()
        url = reverse("order-transition-pending-to-paid", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_transition_paid_to_processing_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="paid_to_processing_Admin")
        _role_user.role = "Admin"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Paid"
        self.obj.save()
        url = reverse("order-transition-paid-to-processing", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Processing")

    def test_transition_processing_to_shipped_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="processing_to_shipped_Admin")
        _role_user.role = "Admin"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Processing"
        self.obj.tracking_number = "test"  # @on: tracking_number != null
        self.obj.save()
        url = reverse("order-transition-processing-to-shipped", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Shipped")

    def test_transition_processing_to_shipped_fails_when_tracking_number_missing(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="processing_to_shipped_tracking_number_missing_Admin")
        _role_user.role = "Admin"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Processing"
        self.obj.tracking_number = None
        self.obj.save()
        url = reverse("order-transition-processing-to-shipped", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_transition_shipped_to_completed_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="shipped_to_completed_Admin")
        _role_user.role = "Admin"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Shipped"
        self.obj.save()
        url = reverse("order-transition-shipped-to-completed", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Completed")

    def test_transition_pending_to_cancelled_succeeds(self):
        self.obj.status = "Pending"
        self.obj.save()
        url = reverse("order-transition-pending-to-cancelled", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Cancelled")

    def test_transition_paid_to_cancelled_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="paid_to_cancelled_Admin")
        _role_user.role = "Admin"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Paid"
        self.obj.save()
        url = reverse("order-transition-paid-to-cancelled", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Cancelled")

    def test_transition_completed_to_refunded_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="completed_to_refunded_Admin")
        _role_user.role = "Admin"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Completed"
        self.obj.save()
        url = reverse("order-transition-completed-to-refunded", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Refunded")

    def test_transition_refunded_to_completed_is_denied(self):
        url = reverse("order-transition-refunded-to-completed", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, 409)

    def test_transition_completed_to_cancelled_is_denied(self):
        url = reverse("order-transition-completed-to-cancelled", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, 409)


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

    def test_search_returns_200(self):
        res = self.client.get(self.list_url + "?q=test")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "code": "test2",
            "discount_value": 1,
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
        _dep_card_set = _CardSetCls.objects.create(name="test", code="AA", release_date="2024-01-01", total_cards=1)
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

    def test_search_returns_200(self):
        res = self.client.get(self.list_url + "?q=test")
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_returns_201(self):
        data = {
            "asking_price": "0.00",
            "auction_start_price": "0.00",
            "auctionEndTime": "2024-01-01T00:00:00Z",
            "quantity": 1,
            "createdAt": "2024-01-01T00:00:00Z",
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

    def test_create_fails_when_fixed_price_requires_asking_price_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"createdAt": "2024-01-01T00:00:00Z", "seller": self.player.pk, "card": self.card.pk, "listing_type": "FixedPrice", "asking_price": None}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_auction_requires_start_price_and_end_time_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"createdAt": "2024-01-01T00:00:00Z", "seller": self.player.pk, "card": self.card.pk, "listing_type": "Auction", "auction_start_price": None}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_fails_when_quantity_positive_violated(self):
        # Simple rule violated → 400
        data = {"createdAt": "2024-01-01T00:00:00Z", "seller": self.player.pk, "card": self.card.pk, "listing_type": "Auction", "asking_price": "0.00", "auction_start_price": "0.00", "auctionEndTime": "2024-01-01T00:00:00Z", "quantity": 10000}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_transition_pending_to_active_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="pending_to_active_Seller")
        _role_user.role = "Seller"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Pending"
        self.obj.quantity = 0  # @on: quantity != null
        self.obj.save()
        url = reverse("trade_listing-transition-pending-to-active", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Active")

    def test_transition_active_to_sold_succeeds(self):
        self.obj.status = "Active"
        self.obj.save()
        url = reverse("trade_listing-transition-active-to-sold", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Sold")

    def test_transition_active_to_expired_succeeds(self):
        self.obj.status = "Active"
        self.obj.save()
        url = reverse("trade_listing-transition-active-to-expired", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Expired")

    def test_transition_active_to_cancelled_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="active_to_cancelled_Seller")
        _role_user.role = "Seller"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Active"
        self.obj.save()
        url = reverse("trade_listing-transition-active-to-cancelled", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Cancelled")

    def test_transition_sold_to_active_is_denied(self):
        url = reverse("trade_listing-transition-sold-to-active", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, 409)

    def test_transition_expired_to_active_is_denied(self):
        url = reverse("trade_listing-transition-expired-to-active", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, 409)


class TradeBidAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="AA", release_date="2024-01-01", total_cards=1)
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
            "placedAt": "2024-01-01T00:00:00Z",
            "listing": self.tradelisting.pk,
            "bidder": self.player.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_fails_when_amount_positive_violated(self):
        # Simple rule violated → 400
        data = {"amount": 0, "placedAt": "2024-01-01T00:00:00Z", "listing": self.tradelisting.pk, "bidder": self.player.pk}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class TradeTransactionAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="AA", release_date="2024-01-01", total_cards=1)
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

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)


class CardPriceHistoryAPITest(APITestCase):
    def setUp(self):
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="AA", release_date="2024-01-01", total_cards=1)
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

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)


class TradeDisputeAPITest(APITestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="AA", release_date="2024-01-01", total_cards=1)
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
        _fresh_trade_listing = TradeListing.objects.create(seller=self.player, card=self.card, asking_price="0.00", auction_start_price="0.00", auction_end_time="2024-01-01T00:00:00Z", quantity=1, created_at="2024-01-01T00:00:00Z")
        _fresh_trade_transaction = TradeTransaction.objects.create(listing=_fresh_trade_listing, buyer=self.player, seller=self.player, final_price=1, platform_fee="1.00", completed_at="2024-01-01T00:00:00Z")
        data = {
            "reason": "ItemNotReceived",
            "description": "test",
            "openedAt": "2024-01-01T00:00:00Z",
            "transaction": _fresh_trade_transaction.pk,
            "opened_by": self.player.pk
        }
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

    def test_retrieve_returns_200(self):
        res = self.client.get(self.detail_url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_create_fails_when_resolved_at_requires_terminal_status_violated(self):
        # IMPLIES: antecedent=true, consequent violated → 400
        data = {"reason": "ItemNotReceived", "description": "test", "openedAt": "2024-01-01T00:00:00Z", "transaction": self.tradetransaction.pk, "opened_by": self.player.pk, "resolvedAt": "2024-01-01T00:00:00Z"}
        res = self.client.post(self.list_url, data, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_transition_open_to_underreview_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="open_to_underreview_Admin")
        _role_user.role = "Admin"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Open"
        self.obj.save()
        url = reverse("trade_dispute-transition-open-to-underreview", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "UnderReview")

    def test_transition_underreview_to_resolved_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="underreview_to_resolved_Admin")
        _role_user.role = "Admin"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "UnderReview"
        self.obj.resolution = "test"  # @on: resolution != null
        self.obj.save()
        url = reverse("trade_dispute-transition-underreview-to-resolved", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Resolved")

    def test_transition_underreview_to_resolved_fails_when_resolution_missing(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="underreview_to_resolved_resolution_missing_Admin")
        _role_user.role = "Admin"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "UnderReview"
        self.obj.resolution = None
        self.obj.save()
        url = reverse("trade_dispute-transition-underreview-to-resolved", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_transition_underreview_to_escalated_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="underreview_to_escalated_Admin")
        _role_user.role = "Admin"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "UnderReview"
        self.obj.save()
        url = reverse("trade_dispute-transition-underreview-to-escalated", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Escalated")

    def test_transition_escalated_to_resolved_succeeds(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="escalated_to_resolved_Admin")
        _role_user.role = "Admin"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Escalated"
        self.obj.resolution = "test"  # @on: resolution != null
        self.obj.save()
        url = reverse("trade_dispute-transition-escalated-to-resolved", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.obj.refresh_from_db()
        self.assertEqual(self.obj.status, "Resolved")

    def test_transition_escalated_to_resolved_fails_when_resolution_missing(self):
        from django.contrib.auth import get_user_model
        _role_user = get_user_model().objects.create(username="escalated_to_resolved_resolution_missing_Admin")
        _role_user.role = "Admin"
        self.client.force_authenticate(user=_role_user)
        self.obj.status = "Escalated"
        self.obj.resolution = None
        self.obj.save()
        url = reverse("trade_dispute-transition-escalated-to-resolved", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_transition_resolved_to_open_is_denied(self):
        url = reverse("trade_dispute-transition-resolved-to-open", args=[self.obj.pk])
        res = self.client.patch(url)
        self.assertEqual(res.status_code, 409)
