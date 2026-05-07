from django.contrib import admin
from .models import Card, CardSet, CardRuling, CardAbility, Deck, DeckCard, DeckSideboardCard, DeckTag, DeckTagAssignment


@admin.register(Card)
class CardAdmin(admin.ModelAdmin):
    list_display = ["id", "name", "card_type", "rarity", "mana_cost"]
    search_fields = ["name", "card_type", "rarity"]
    list_filter = ["card_type", "rarity", "mana_colors", "legal_formats", "set"]


@admin.register(CardSet)
class CardSetAdmin(admin.ModelAdmin):
    list_display = ["id", "name", "code", "release_date", "set_type"]
    search_fields = ["name", "code", "set_type"]
    list_filter = ["set_type"]


@admin.register(CardRuling)
class CardRulingAdmin(admin.ModelAdmin):
    list_display = ["id", "ruling_text", "published_at", "source", "card"]
    search_fields = ["ruling_text", "source"]
    list_filter = ["card"]


@admin.register(CardAbility)
class CardAbilityAdmin(admin.ModelAdmin):
    list_display = ["id", "ability_type", "keyword", "ability_text", "timing"]
    search_fields = ["ability_type", "keyword", "ability_text"]
    list_filter = ["ability_type", "timing", "card"]


@admin.register(Deck)
class DeckAdmin(admin.ModelAdmin):
    list_display = ["id", "name", "description", "format", "is_public"]
    search_fields = ["name", "description", "format"]
    list_filter = ["format", "archetype", "player"]


@admin.register(DeckCard)
class DeckCardAdmin(admin.ModelAdmin):
    list_display = ["id", "quantity", "is_commander", "deck", "card"]
    list_filter = ["deck", "card"]


@admin.register(DeckSideboardCard)
class DeckSideboardCardAdmin(admin.ModelAdmin):
    list_display = ["id", "quantity", "deck", "card"]
    list_filter = ["deck", "card"]


@admin.register(DeckTag)
class DeckTagAdmin(admin.ModelAdmin):
    list_display = ["id", "name", "color"]
    search_fields = ["name", "color"]


@admin.register(DeckTagAssignment)
class DeckTagAssignmentAdmin(admin.ModelAdmin):
    list_display = ["id", "deck", "tag"]
    list_filter = ["deck", "tag"]
