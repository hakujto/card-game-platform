from django.conf import settings
from django.db import models


class CardTypeChoices(models.TextChoices):
    CREATURE = "Creature", "Creature"
    SPELL = "Spell", "Spell"
    LAND = "Land", "Land"
    ARTIFACT = "Artifact", "Artifact"
    ENCHANTMENT = "Enchantment", "Enchantment"
    PLANESWALKER = "Planeswalker", "Planeswalker"


class RarityChoices(models.TextChoices):
    COMMON = "Common", "Common"
    UNCOMMON = "Uncommon", "Uncommon"
    RARE = "Rare", "Rare"
    MYTHICRARE = "MythicRare", "Mythicrare"
    LEGENDARY = "Legendary", "Legendary"


class ManaColorsChoices(models.TextChoices):
    WHITE = "White", "White"
    BLUE = "Blue", "Blue"
    BLACK = "Black", "Black"
    RED = "Red", "Red"
    GREEN = "Green", "Green"
    COLORLESS = "Colorless", "Colorless"


class LegalFormatsChoices(models.TextChoices):
    STANDARD = "Standard", "Standard"
    EXTENDED = "Extended", "Extended"
    LEGACY = "Legacy", "Legacy"
    VINTAGE = "Vintage", "Vintage"
    COMMANDER = "Commander", "Commander"
    DRAFT = "Draft", "Draft"


class Card(models.Model):
    name = models.CharField(max_length=200)
    card_type = models.CharField(max_length=20, choices=CardTypeChoices.choices, default=CardTypeChoices.CREATURE)
    rarity = models.CharField(max_length=20, choices=RarityChoices.choices, default=RarityChoices.COMMON)
    mana_cost = models.IntegerField(default=0)
    mana_colors = models.CharField(max_length=20, choices=ManaColorsChoices.choices)
    attack = models.IntegerField(null=True, blank=True)
    defense = models.IntegerField(null=True, blank=True)
    loyalty = models.IntegerField(null=True, blank=True)
    description = models.TextField()
    flavor_text = models.TextField(null=True, blank=True)
    image_url = models.URLField(max_length=200, null=True, blank=True)
    artist_name = models.CharField(max_length=100, null=True, blank=True)
    legal_formats = models.CharField(max_length=20, choices=LegalFormatsChoices.choices)
    is_banned = models.BooleanField(default=False)
    is_restricted = models.BooleanField(default=False)
    power_level = models.IntegerField(default=1)
    set = models.ForeignKey("CardSet", on_delete=models.CASCADE, related_name="cards")

    class Meta:
        verbose_name = "Card"
        verbose_name_plural = "Cards"
        ordering = ["-id"]

    def __str__(self):
        return str(self.name)

    # ── Business operations ──────────────────────────────────────────

    def ban(self):
        raise NotImplementedError("ban not implemented")

    def unban(self):
        raise NotImplementedError("unban not implemented")

    def restrict(self):
        raise NotImplementedError("restrict not implemented")

    def unrestrict(self):
        raise NotImplementedError("unrestrict not implemented")

    def calculate_value(self):
        raise NotImplementedError("calculate_value not implemented")


class SetTypeChoices(models.TextChoices):
    CORE = "Core", "Core"
    EXPANSION = "Expansion", "Expansion"
    SUPPLEMENTAL = "Supplemental", "Supplemental"
    MASTERS = "Masters", "Masters"
    DRAFT = "Draft", "Draft"


class CardSet(models.Model):
    name = models.CharField(max_length=200)
    code = models.CharField(max_length=10)
    release_date = models.DateField()
    set_type = models.CharField(max_length=20, choices=SetTypeChoices.choices, default=SetTypeChoices.EXPANSION)
    total_cards = models.IntegerField()
    description = models.TextField(null=True, blank=True)
    logo_url = models.URLField(max_length=200, null=True, blank=True)

    class Meta:
        verbose_name = "Card Set"
        verbose_name_plural = "Card Sets"
        ordering = ["-id"]

    def __str__(self):
        return str(self.name)

    # ── Business operations ──────────────────────────────────────────

    def is_legal_in_standard(self):
        raise NotImplementedError("is_legal_in_standard not implemented")


class CardRuling(models.Model):
    ruling_text = models.TextField()
    published_at = models.DateField()
    source = models.CharField(max_length=200)
    card = models.ForeignKey("Card", on_delete=models.CASCADE)

    class Meta:
        verbose_name = "Card Ruling"
        verbose_name_plural = "Card Rulings"
        ordering = ["-id"]

    def __str__(self):
        return str(self.ruling_text)

    # ── Business operations ──────────────────────────────────────────

    def is_current(self):
        raise NotImplementedError("is_current not implemented")

    def supersedes_previous(self):
        raise NotImplementedError("supersedes_previous not implemented")


class AbilityTypeChoices(models.TextChoices):
    KEYWORD = "Keyword", "Keyword"
    ACTIVATED = "Activated", "Activated"
    TRIGGERED = "Triggered", "Triggered"
    STATIC = "Static", "Static"


class TimingChoices(models.TextChoices):
    ANY = "Any", "Any"
    SORCERY = "Sorcery", "Sorcery"
    INSTANT = "Instant", "Instant"
    COMBAT = "Combat", "Combat"


class CardAbility(models.Model):
    ability_type = models.CharField(max_length=20, choices=AbilityTypeChoices.choices, default=AbilityTypeChoices.KEYWORD)
    keyword = models.CharField(max_length=100, null=True, blank=True)
    ability_text = models.TextField()
    timing = models.CharField(max_length=20, choices=TimingChoices.choices, null=True, blank=True)
    card = models.ForeignKey("Card", on_delete=models.CASCADE)

    class Meta:
        verbose_name = "Card Ability"
        verbose_name_plural = "Card Abilities"
        ordering = ["-id"]

    def __str__(self):
        return str(self.ability_type)

    # ── Business operations ──────────────────────────────────────────

    def is_usable_at(self, timing):
        raise NotImplementedError("is_usable_at not implemented")

    def describe(self):
        raise NotImplementedError("describe not implemented")


class FormatChoices(models.TextChoices):
    STANDARD = "Standard", "Standard"
    EXTENDED = "Extended", "Extended"
    LEGACY = "Legacy", "Legacy"
    VINTAGE = "Vintage", "Vintage"
    COMMANDER = "Commander", "Commander"
    DRAFT = "Draft", "Draft"


class ArchetypeChoices(models.TextChoices):
    AGGRO = "Aggro", "Aggro"
    CONTROL = "Control", "Control"
    MIDRANGE = "Midrange", "Midrange"
    COMBO = "Combo", "Combo"
    PRISON = "Prison", "Prison"
    TEMPO = "Tempo", "Tempo"


class Deck(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(null=True, blank=True)
    format = models.CharField(max_length=20, choices=FormatChoices.choices, default=FormatChoices.STANDARD)
    is_public = models.BooleanField(default=False)
    is_tournament_legal = models.BooleanField(default=False)
    archetype = models.CharField(max_length=20, choices=ArchetypeChoices.choices, null=True, blank=True)
    wins = models.IntegerField(default=0)
    losses = models.IntegerField(default=0)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    player = models.ForeignKey("players.Player", on_delete=models.CASCADE, related_name="decks")
    cards = models.ManyToManyField("Card", through="DeckCard", related_name="+")
    sideboard_cards = models.ManyToManyField("Card", through="DeckSideboardCard", related_name="+")
    tags = models.ManyToManyField("DeckTag", through="DeckTagAssignment")

    class Meta:
        verbose_name = "Deck"
        verbose_name_plural = "Decks"
        ordering = ["-id"]

    def __str__(self):
        return str(self.name)

    # ── Business operations ──────────────────────────────────────────

    def validate_size(self):
        raise NotImplementedError("validate_size not implemented")

    def clone(self):
        raise NotImplementedError("clone not implemented")

    def publish(self):
        raise NotImplementedError("publish not implemented")

    def unpublish(self):
        raise NotImplementedError("unpublish not implemented")

    def certify_tournament_legal(self):
        raise NotImplementedError("certify_tournament_legal not implemented")


class DeckCard(models.Model):
    quantity = models.IntegerField(default=1)
    is_commander = models.BooleanField(default=False)
    deck = models.ForeignKey("Deck", on_delete=models.CASCADE, related_name="deck_cards")
    card = models.ForeignKey("Card", on_delete=models.CASCADE, related_name="deck_cards")

    class Meta:
        verbose_name = "Deck Card"
        verbose_name_plural = "Deck Cards"
        ordering = ["-id"]

    def __str__(self):
        return str(self.quantity)


class DeckSideboardCard(models.Model):
    quantity = models.IntegerField(default=1)
    deck = models.ForeignKey("Deck", on_delete=models.CASCADE)
    card = models.ForeignKey("Card", on_delete=models.CASCADE, related_name="+")

    class Meta:
        verbose_name = "Deck Sideboard Card"
        verbose_name_plural = "Deck Sideboard Cards"
        ordering = ["-id"]

    def __str__(self):
        return str(self.quantity)

    # ── Business operations ──────────────────────────────────────────

    def increment(self, amount):
        raise NotImplementedError("increment not implemented")

    def decrement(self, amount):
        raise NotImplementedError("decrement not implemented")


class DeckTag(models.Model):
    name = models.CharField(max_length=50)
    color = models.CharField(max_length=7, null=True, blank=True)

    class Meta:
        verbose_name = "Deck Tag"
        verbose_name_plural = "Deck Tags"
        ordering = ["-id"]

    def __str__(self):
        return str(self.name)

    # ── Business operations ──────────────────────────────────────────

    def rename(self, new_name):
        raise NotImplementedError("rename not implemented")

    def merge_into(self, target_tag_id):
        raise NotImplementedError("merge_into not implemented")


class DeckTagAssignment(models.Model):
    deck = models.ForeignKey("Deck", on_delete=models.CASCADE, related_name="tag_assignments")
    tag = models.ForeignKey("DeckTag", on_delete=models.CASCADE, related_name="deck_assignments")

    class Meta:
        verbose_name = "Deck Tag Assignment"
        verbose_name_plural = "Deck Tag Assignments"
        ordering = ["-id"]

    def __str__(self):
        return str(self.id)
