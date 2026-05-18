from django.conf import settings
from django.db import models


class CardCardTypeChoices(models.TextChoices):
    CREATURE = "Creature", "Creature"
    SPELL = "Spell", "Spell"
    LAND = "Land", "Land"
    ARTIFACT = "Artifact", "Artifact"
    ENCHANTMENT = "Enchantment", "Enchantment"
    PLANESWALKER = "Planeswalker", "Planeswalker"


class CardRarityChoices(models.TextChoices):
    COMMON = "Common", "Common"
    UNCOMMON = "Uncommon", "Uncommon"
    RARE = "Rare", "Rare"
    MYTHICRARE = "MythicRare", "Mythicrare"
    LEGENDARY = "Legendary", "Legendary"


class CardManaColorsChoices(models.TextChoices):
    WHITE = "White", "White"
    BLUE = "Blue", "Blue"
    BLACK = "Black", "Black"
    RED = "Red", "Red"
    GREEN = "Green", "Green"
    COLORLESS = "Colorless", "Colorless"


class CardLegalFormatsChoices(models.TextChoices):
    STANDARD = "Standard", "Standard"
    EXTENDED = "Extended", "Extended"
    LEGACY = "Legacy", "Legacy"
    VINTAGE = "Vintage", "Vintage"
    COMMANDER = "Commander", "Commander"
    DRAFT = "Draft", "Draft"


class Card(models.Model):
    name = models.CharField(max_length=200)
    card_type = models.CharField(max_length=20, choices=CardCardTypeChoices.choices, default=CardCardTypeChoices.CREATURE)
    rarity = models.CharField(max_length=20, choices=CardRarityChoices.choices, default=CardRarityChoices.COMMON)
    mana_cost = models.IntegerField(default=0)
    mana_colors = models.CharField(max_length=20, choices=CardManaColorsChoices.choices)
    attack = models.IntegerField(null=True, blank=True)
    defense = models.IntegerField(null=True, blank=True)
    loyalty = models.IntegerField(null=True, blank=True)
    description = models.TextField()
    flavor_text = models.TextField(null=True, blank=True)
    image_url = models.URLField(max_length=200, null=True, blank=True)
    artist_name = models.CharField(max_length=100, null=True, blank=True)
    legal_formats = models.CharField(max_length=20, choices=CardLegalFormatsChoices.choices)
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

    def apply_rarity_bonus(self, multiplier):
        raise NotImplementedError("apply_rarity_bonus not implemented")

    def is_legal_in_format(self, format):
        raise NotImplementedError("is_legal_in_format not implemented")

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.mana_cost is None or (self.mana_cost >= 0 and self.mana_cost <= 20))):
            errors["mana_cost_range"] = "mana_cost must be between 0 and 20"
        if not ((self.power_level is None or (self.power_level >= 1 and self.power_level <= 10))):
            errors["power_level_range"] = "power_level must be between 1 and 10"
        if not (not ((self.is_banned is True and self.is_restricted is True))):
            errors["not_banned_and_restricted"] = "Card cannot be both banned and restricted at the same time"
        if errors:
            raise ValidationError(errors)

    def validate_implies(self):
        from django.core.exceptions import ValidationError
        if (self.card_type == CardCardTypeChoices.CREATURE) and (not ((self.attack is not None and self.defense is not None))):
            raise ValidationError({"creature_requires_stats": "Creature card must have attack and defense"})
        if (self.card_type == CardCardTypeChoices.PLANESWALKER) and (self.loyalty is None):
            raise ValidationError({"planeswalker_requires_loyalty": "Planeswalker card must have loyalty"})
        if (self.card_type != CardCardTypeChoices.PLANESWALKER) and (self.loyalty is not None):
            raise ValidationError({"spell_or_artifact_no_loyalty": "Only Planeswalker cards can have loyalty"})
        if (self.is_banned is True) and (not (self.legal_formats == "message")):
            raise ValidationError({"banned_card_not_in_legal_formats": "banned_card_not_in_legal_formats"})


class CardSetSetTypeChoices(models.TextChoices):
    CORE = "Core", "Core"
    EXPANSION = "Expansion", "Expansion"
    SUPPLEMENTAL = "Supplemental", "Supplemental"
    MASTERS = "Masters", "Masters"
    DRAFT = "Draft", "Draft"


class CardSet(models.Model):
    name = models.CharField(max_length=200)
    code = models.CharField(max_length=10)
    release_date = models.DateField()
    rotation_date = models.DateField(null=True, blank=True)
    set_type = models.CharField(max_length=20, choices=CardSetSetTypeChoices.choices, default=CardSetSetTypeChoices.EXPANSION)
    total_cards = models.IntegerField()
    is_rotated = models.BooleanField(default=False)
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

    def is_legal_in_format(self, format):
        raise NotImplementedError("is_legal_in_format not implemented")

    def card_count_by_rarity(self, rarity):
        raise NotImplementedError("card_count_by_rarity not implemented")

    def rotate_out(self):
        raise NotImplementedError("rotate_out not implemented")

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.total_cards is None or self.total_cards > 0)):
            errors["total_cards_positive"] = "Card set must have at least one card"
        if errors:
            raise ValidationError(errors)

    def validate_implies(self):
        from django.core.exceptions import ValidationError
        if (self.rotation_date is not None) and (not ((self.rotation_date is None or (self.release_date is not None and self.rotation_date > self.release_date)))):
            raise ValidationError({"rotation_date_after_release": "Rotation date must be after release date"})
        if (self.is_rotated is True) and (self.rotation_date is None):
            raise ValidationError({"rotated_set_has_rotation_date": "Rotated set must have a rotation date"})


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


class CardAbilityAbilityTypeChoices(models.TextChoices):
    KEYWORD = "Keyword", "Keyword"
    ACTIVATED = "Activated", "Activated"
    TRIGGERED = "Triggered", "Triggered"
    STATIC = "Static", "Static"


class CardAbilityTimingChoices(models.TextChoices):
    ANY = "Any", "Any"
    SORCERY = "Sorcery", "Sorcery"
    INSTANT = "Instant", "Instant"
    COMBAT = "Combat", "Combat"


class CardAbility(models.Model):
    ability_type = models.CharField(max_length=20, choices=CardAbilityAbilityTypeChoices.choices, default=CardAbilityAbilityTypeChoices.KEYWORD)
    keyword = models.CharField(max_length=100, null=True, blank=True)
    ability_text = models.TextField()
    timing = models.CharField(max_length=20, choices=CardAbilityTimingChoices.choices, null=True, blank=True)
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

    def validate_implies(self):
        from django.core.exceptions import ValidationError
        if (self.ability_type == CardAbilityAbilityTypeChoices.KEYWORD) and (self.keyword is None):
            raise ValidationError({"keyword_ability_requires_keyword": "Keyword ability must have a keyword name"})


class DeckFormatChoices(models.TextChoices):
    STANDARD = "Standard", "Standard"
    EXTENDED = "Extended", "Extended"
    LEGACY = "Legacy", "Legacy"
    VINTAGE = "Vintage", "Vintage"
    COMMANDER = "Commander", "Commander"
    DRAFT = "Draft", "Draft"


class DeckArchetypeChoices(models.TextChoices):
    AGGRO = "Aggro", "Aggro"
    CONTROL = "Control", "Control"
    MIDRANGE = "Midrange", "Midrange"
    COMBO = "Combo", "Combo"
    PRISON = "Prison", "Prison"
    TEMPO = "Tempo", "Tempo"


class Deck(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(null=True, blank=True)
    format = models.CharField(max_length=20, choices=DeckFormatChoices.choices, default=DeckFormatChoices.STANDARD)
    is_public = models.BooleanField(default=False)
    is_tournament_legal = models.BooleanField(default=False)
    archetype = models.CharField(max_length=20, choices=DeckArchetypeChoices.choices, null=True, blank=True)
    wins = models.IntegerField(default=0)
    losses = models.IntegerField(default=0)
    draws = models.IntegerField(default=0)
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

    def add_card(self, card_id, quantity):
        raise NotImplementedError("add_card not implemented")

    def remove_card(self, card_id):
        raise NotImplementedError("remove_card not implemented")

    def win_rate(self):
        raise NotImplementedError("win_rate not implemented")

    def clone(self):
        raise NotImplementedError("clone not implemented")

    def publish(self):
        raise NotImplementedError("publish not implemented")

    def unpublish(self):
        raise NotImplementedError("unpublish not implemented")

    def certify_tournament_legal(self):
        raise NotImplementedError("certify_tournament_legal not implemented")

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.wins is None or self.wins >= 0)):
            errors["wins_not_negative"] = "Deck wins count must not be negative"
        if not ((self.losses is None or self.losses >= 0)):
            errors["losses_not_negative"] = "Deck losses count must not be negative"
        if not ((self.draws is None or self.draws >= 0)):
            errors["draws_not_negative"] = "Deck draws count must not be negative"
        if errors:
            raise ValidationError(errors)

    def validate_implies(self):
        from django.core.exceptions import ValidationError
        if (self.is_tournament_legal is True) and (not (self.is_public is True)):
            raise ValidationError({"tournament_legal_deck_must_be_validated": "Tournament-legal deck must be made public"})


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

    # ── Business operations ──────────────────────────────────────────

    def increment(self, amount):
        raise NotImplementedError("increment not implemented")

    def decrement(self, amount):
        raise NotImplementedError("decrement not implemented")

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.quantity is None or (self.quantity >= 1 and self.quantity <= 4))):
            errors["quantity_range"] = "A deck can contain between 1 and 4 copies of a card"
        if errors:
            raise ValidationError(errors)


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

    def clean(self):
        from django.core.exceptions import ValidationError
        errors = {}
        if not ((self.quantity is None or (self.quantity >= 1 and self.quantity <= 4))):
            errors["quantity_range"] = "Sideboard card quantity must be between 1 and 4 copies"
        if errors:
            raise ValidationError(errors)


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
