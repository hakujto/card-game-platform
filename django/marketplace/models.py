from django.conf import settings
from django.db import models


class ProductTypeChoices(models.TextChoices):
    SINGLECARD = "SingleCard", "Singlecard"
    BOOSTERPACK = "BoosterPack", "Boosterpack"
    BUNDLE = "Bundle", "Bundle"
    PRECONSTRUCTEDDECK = "PreconstructedDeck", "Preconstructeddeck"
    ACCESSORY = "Accessory", "Accessory"


class Product(models.Model):
    name = models.CharField(max_length=200)
    product_type = models.CharField(max_length=20, choices=ProductTypeChoices.choices, default=ProductTypeChoices.SINGLECARD)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    stock = models.IntegerField(default=0)
    active = models.BooleanField(default=True)
    discount_percent = models.IntegerField(default=0)
    description = models.TextField(null=True, blank=True)
    image_url = models.URLField(max_length=200, null=True, blank=True)
    featured = models.BooleanField(default=False)
    card = models.OneToOneField("cards.Card", on_delete=models.CASCADE, related_name="shop_product", null=True, blank=True)
    card_set = models.ForeignKey("cards.CardSet", on_delete=models.CASCADE, related_name="shop_products", null=True, blank=True)

    class Meta:
        verbose_name = "Product"
        verbose_name_plural = "Products"
        ordering = ["-id"]

    def __str__(self):
        return str(self.name)

    # ── Business operations ──────────────────────────────────────────

    def activate(self):
        raise NotImplementedError("activate not implemented")

    def deactivate(self):
        raise NotImplementedError("deactivate not implemented")

    def apply_discount(self, percent):
        raise NotImplementedError("apply_discount not implemented")

    def restock(self, quantity):
        raise NotImplementedError("restock not implemented")

    def effective_price(self):
        raise NotImplementedError("effective_price not implemented")

    def is_in_stock(self):
        raise NotImplementedError("is_in_stock not implemented")


class StatusChoices(models.TextChoices):
    PENDING = "Pending", "Pending"
    PAID = "Paid", "Paid"
    PROCESSING = "Processing", "Processing"
    SHIPPED = "Shipped", "Shipped"
    COMPLETED = "Completed", "Completed"
    CANCELLED = "Cancelled", "Cancelled"
    REFUNDED = "Refunded", "Refunded"


class PaymentMethodChoices(models.TextChoices):
    CARD = "Card", "Card"
    PAYPAL = "PayPal", "Paypal"
    CRYPTO = "Crypto", "Crypto"
    PLATFORMCREDITS = "PlatformCredits", "Platformcredits"


class Order(models.Model):
    status = models.CharField(max_length=20, choices=StatusChoices.choices, default=StatusChoices.PENDING)
    total = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    discount_applied = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    currency = models.CharField(max_length=3, default="USD")
    payment_method = models.CharField(max_length=20, choices=PaymentMethodChoices.choices, null=True, blank=True)
    payment_reference = models.CharField(max_length=200, null=True, blank=True)
    shipping_address = models.TextField(null=True, blank=True)
    tracking_number = models.CharField(max_length=100, null=True, blank=True)
    created_at = models.DateTimeField()
    paid_at = models.DateTimeField(null=True, blank=True)
    shipped_at = models.DateTimeField(null=True, blank=True)
    player = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="orders")
    coupon = models.ForeignKey("Coupon", on_delete=models.CASCADE, related_name="orders", null=True, blank=True)

    class Meta:
        verbose_name = "Order"
        verbose_name_plural = "Orders"
        ordering = ["-id"]

    def __str__(self):
        return str(self.status)

    # ── Business operations ──────────────────────────────────────────

    def cancel(self):
        raise NotImplementedError("cancel not implemented")

    def pay(self, payment_ref):
        raise NotImplementedError("pay not implemented")

    def calculate_total(self):
        raise NotImplementedError("calculate_total not implemented")

    def apply_discount(self, percent):
        raise NotImplementedError("apply_discount not implemented")

    def refund(self):
        raise NotImplementedError("refund not implemented")

    def notify_shipped(self):
        raise NotImplementedError("notify_shipped not implemented")


class OrderItem(models.Model):
    quantity = models.IntegerField()
    price_at_purchase = models.DecimalField(max_digits=10, decimal_places=2)
    foil = models.BooleanField(default=False)
    order = models.ForeignKey("Order", on_delete=models.CASCADE, null=True, blank=True)
    product = models.ForeignKey("Product", on_delete=models.CASCADE, related_name="order_items")

    class Meta:
        verbose_name = "Order Item"
        verbose_name_plural = "Order Items"
        ordering = ["-id"]

    def __str__(self):
        return str(self.quantity)

    # ── Business operations ──────────────────────────────────────────

    def line_total(self):
        raise NotImplementedError("line_total not implemented")


class DiscountTypeChoices(models.TextChoices):
    PERCENT = "Percent", "Percent"
    FIXED = "Fixed", "Fixed"


class Coupon(models.Model):
    code = models.CharField(max_length=50)
    discount_type = models.CharField(max_length=20, choices=DiscountTypeChoices.choices, default=DiscountTypeChoices.PERCENT)
    discount_value = models.DecimalField(max_digits=10, decimal_places=2)
    min_order_value = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    max_uses = models.IntegerField(null=True, blank=True)
    uses_count = models.IntegerField(default=0)
    valid_from = models.DateTimeField()
    valid_until = models.DateTimeField()
    is_active = models.BooleanField(default=True)

    class Meta:
        verbose_name = "Coupon"
        verbose_name_plural = "Coupons"
        ordering = ["-id"]

    def __str__(self):
        return str(self.code)

    # ── Business operations ──────────────────────────────────────────

    def is_valid(self):
        raise NotImplementedError("is_valid not implemented")

    def is_applicable_to_order(self, order_total):
        raise NotImplementedError("is_applicable_to_order not implemented")

    def redeem(self):
        raise NotImplementedError("redeem not implemented")

    def deactivate(self):
        raise NotImplementedError("deactivate not implemented")


class ListingTypeChoices(models.TextChoices):
    FIXEDPRICE = "FixedPrice", "Fixedprice"
    AUCTION = "Auction", "Auction"
    TRADEOFFER = "TradeOffer", "Tradeoffer"


class ConditionChoices(models.TextChoices):
    MINT = "Mint", "Mint"
    NEARMINT = "NearMint", "Nearmint"
    EXCELLENT = "Excellent", "Excellent"
    GOOD = "Good", "Good"
    PLAYED = "Played", "Played"


class StatusChoices(models.TextChoices):
    ACTIVE = "Active", "Active"
    SOLD = "Sold", "Sold"
    EXPIRED = "Expired", "Expired"
    CANCELLED = "Cancelled", "Cancelled"
    PENDING = "Pending", "Pending"


class Tradelisting(models.Model):
    listing_type = models.CharField(max_length=20, choices=ListingTypeChoices.choices, default=ListingTypeChoices.FIXEDPRICE)
    asking_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    auction_start_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    auction_current_bid = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    auction_end_time = models.DateTimeField(null=True, blank=True)
    foil = models.BooleanField(default=False)
    condition = models.CharField(max_length=20, choices=ConditionChoices.choices, default=ConditionChoices.MINT)
    quantity = models.IntegerField(default=1)
    status = models.CharField(max_length=20, choices=StatusChoices.choices, default=StatusChoices.ACTIVE)
    description = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField()
    expires_at = models.DateTimeField(null=True, blank=True)
    seller = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="trade_listings")
    card = models.ForeignKey("cards.Card", on_delete=models.CASCADE, related_name="trade_listings")

    class Meta:
        verbose_name = "Tradelisting"
        verbose_name_plural = "Tradelistings"
        ordering = ["-id"]

    def __str__(self):
        return str(self.listing_type)

    # ── Business operations ──────────────────────────────────────────

    def close(self):
        raise NotImplementedError("close not implemented")

    def extend(self, days):
        raise NotImplementedError("extend not implemented")

    def cancel(self):
        raise NotImplementedError("cancel not implemented")

    def is_expired(self):
        raise NotImplementedError("is_expired not implemented")

    def finalize_auction(self):
        raise NotImplementedError("finalize_auction not implemented")


class TradeBid(models.Model):
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    placed_at = models.DateTimeField()
    is_winning = models.BooleanField(default=False)
    listing = models.ForeignKey("TradeListing", on_delete=models.CASCADE)
    bidder = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="bids")

    class Meta:
        verbose_name = "Trade Bid"
        verbose_name_plural = "Trade Bids"
        ordering = ["-id"]

    def __str__(self):
        return str(self.amount)

    # ── Business operations ──────────────────────────────────────────

    def outbid_by(self, new_amount):
        raise NotImplementedError("outbid_by not implemented")


class StatusChoices(models.TextChoices):
    PENDING = "Pending", "Pending"
    COMPLETED = "Completed", "Completed"
    DISPUTED = "Disputed", "Disputed"
    REFUNDED = "Refunded", "Refunded"


class TradeTransaction(models.Model):
    final_price = models.DecimalField(max_digits=10, decimal_places=2)
    platform_fee = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, choices=StatusChoices.choices, default=StatusChoices.PENDING)
    completed_at = models.DateTimeField(null=True, blank=True)
    listing = models.OneToOneField("TradeListing", on_delete=models.CASCADE, related_name="transaction")
    buyer = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="purchases")
    seller = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="sales")

    class Meta:
        verbose_name = "Trade Transaction"
        verbose_name_plural = "Trade Transactions"
        ordering = ["-id"]

    def __str__(self):
        return str(self.final_price)

    # ── Business operations ──────────────────────────────────────────

    def complete(self):
        raise NotImplementedError("complete not implemented")

    def refund(self):
        raise NotImplementedError("refund not implemented")

    def open_dispute(self, reason):
        raise NotImplementedError("open_dispute not implemented")

    def seller_net(self):
        raise NotImplementedError("seller_net not implemented")


class CardPriceHistory(models.Model):
    price_date = models.DateField()
    avg_price = models.DecimalField(max_digits=10, decimal_places=2)
    min_price = models.DecimalField(max_digits=10, decimal_places=2)
    max_price = models.DecimalField(max_digits=10, decimal_places=2)
    volume = models.IntegerField()
    foil = models.BooleanField(default=False)
    card = models.ForeignKey("cards.Card", on_delete=models.CASCADE, related_name="price_history")

    class Meta:
        verbose_name = "Card Price History"
        verbose_name_plural = "Card Price Histories"
        ordering = ["-id"]

    def __str__(self):
        return str(self.price_date)

    # ── Business operations ──────────────────────────────────────────

    def price_change_percent(self, previous_avg):
        raise NotImplementedError("price_change_percent not implemented")

    def is_price_spike(self, threshold_percent):
        raise NotImplementedError("is_price_spike not implemented")


class ReasonChoices(models.TextChoices):
    ITEMNOTRECEIVED = "ItemNotReceived", "Itemnotreceived"
    ITEMNOTASDESCRIBED = "ItemNotAsDescribed", "Itemnotasdescribed"
    FRAUDSUSPECTED = "FraudSuspected", "Fraudsuspected"
    OTHER = "Other", "Other"


class StatusChoices(models.TextChoices):
    OPEN = "Open", "Open"
    UNDERREVIEW = "UnderReview", "Underreview"
    RESOLVED = "Resolved", "Resolved"
    ESCALATED = "Escalated", "Escalated"


class TradeDispute(models.Model):
    reason = models.CharField(max_length=20, choices=ReasonChoices.choices)
    description = models.TextField()
    status = models.CharField(max_length=20, choices=StatusChoices.choices, default=StatusChoices.OPEN)
    resolution = models.TextField(null=True, blank=True)
    opened_at = models.DateTimeField()
    resolved_at = models.DateTimeField(null=True, blank=True)
    transaction = models.OneToOneField("TradeTransaction", on_delete=models.CASCADE, related_name="dispute")
    opened_by = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="disputes_opened")
    resolved_by = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="disputes_resolved", null=True, blank=True)

    class Meta:
        verbose_name = "Trade Dispute"
        verbose_name_plural = "Trade Disputes"
        ordering = ["-id"]

    def __str__(self):
        return str(self.reason)

    # ── Business operations ──────────────────────────────────────────

    def escalate(self):
        raise NotImplementedError("escalate not implemented")

    def resolve(self, resolution_text):
        raise NotImplementedError("resolve not implemented")

    def review(self):
        raise NotImplementedError("review not implemented")
