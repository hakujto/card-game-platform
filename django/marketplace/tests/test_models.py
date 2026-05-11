from django.test import TestCase
from ..models import Product, Order, OrderItem, Coupon, Tradelisting, TradeBid, TradeTransaction, CardPriceHistory, TradeDispute


class ProductModelTest(TestCase):
    def setUp(self):
        self.obj = Product.objects.create(name="test", price="0.00")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class OrderModelTest(TestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        self.obj = Order.objects.create(player=_dep_player, created_at="2024-01-01T00:00:00Z")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class OrderItemModelTest(TestCase):
    def setUp(self):
        _dep_product = Product.objects.create(name="test", price="0.00")
        self.obj = OrderItem.objects.create(product=_dep_product, quantity=0, price_at_purchase="0.00")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class CouponModelTest(TestCase):
    def setUp(self):
        self.obj = Coupon.objects.create(code="test", discount_value="0.00", valid_from="2024-01-01T00:00:00Z", valid_until="2024-01-01T00:00:00Z")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class TradelistingModelTest(TestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        self.obj = Tradelisting.objects.create(seller=_dep_player, card=_dep_card, created_at="2024-01-01T00:00:00Z")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class TradeBidModelTest(TestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        _dep_tradelisting = Tradelisting.objects.create(created_at="2024-01-01T00:00:00Z", seller=_dep_player, card=_dep_card)
        self.obj = TradeBid.objects.create(listing=_dep_tradelisting, bidder=_dep_player, amount="0.00", placed_at="2024-01-01T00:00:00Z")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class TradeTransactionModelTest(TestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        _dep_tradelisting = Tradelisting.objects.create(created_at="2024-01-01T00:00:00Z", seller=_dep_player, card=_dep_card)
        self.obj = TradeTransaction.objects.create(listing=_dep_tradelisting, buyer=_dep_player, seller=_dep_player, final_price="0.00", platform_fee="0.00")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class CardPriceHistoryModelTest(TestCase):
    def setUp(self):
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        self.obj = CardPriceHistory.objects.create(card=_dep_card, price_date="2024-01-01", avg_price="0.00", min_price="0.00", max_price="0.00", volume=0)

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)


class TradeDisputeModelTest(TestCase):
    def setUp(self):
        from players.models import Player as _PlayerCls
        _dep_player = _PlayerCls.objects.create(display_name="test", created_at="2024-01-01T00:00:00Z")
        from cards.models import CardSet as _CardSetCls
        _dep_card_set = _CardSetCls.objects.create(name="test", code="test", release_date="2024-01-01", total_cards=0)
        from cards.models import Card as _CardCls
        _dep_card = _CardCls.objects.create(name="test", mana_colors="White", description="test", legal_formats="Standard", set=_dep_card_set)
        _dep_tradelisting = Tradelisting.objects.create(created_at="2024-01-01T00:00:00Z", seller=_dep_player, card=_dep_card)
        _dep_trade_transaction = TradeTransaction.objects.create(final_price="0.00", platform_fee="0.00", listing=_dep_tradelisting, buyer=_dep_player, seller=_dep_player)
        self.obj = TradeDispute.objects.create(transaction=_dep_trade_transaction, opened_by=_dep_player, reason="ItemNotReceived", description="test", opened_at="2024-01-01T00:00:00Z")

    def test_str(self):
        self.assertIsNotNone(str(self.obj))

    def test_save(self):
        self.assertIsNotNone(self.obj.pk)
