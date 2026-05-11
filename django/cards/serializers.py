from rest_framework import serializers
from .models import Card, CardSet, CardRuling, CardAbility, Deck, DeckCard, DeckSideboardCard, DeckTag, DeckTagAssignment


class CardSerializer(serializers.ModelSerializer):
    class Meta:
        model = Card
        fields = [
            "id",
            "name",
            "card_type",
            "rarity",
            "mana_cost",
            "mana_colors",
            "attack",
            "defense",
            "loyalty",
            "description",
            "flavor_text",
            "image_url",
            "artist_name",
            "legal_formats",
            "is_banned",
            "is_restricted",
            "power_level",
            "set",
        ]
        read_only_fields = ["id"]


class CardSetSerializer(serializers.ModelSerializer):
    class Meta:
        model = CardSet
        fields = [
            "id",
            "name",
            "code",
            "release_date",
            "set_type",
            "total_cards",
            "description",
            "logo_url",
        ]
        read_only_fields = ["id"]


class CardRulingSerializer(serializers.ModelSerializer):
    class Meta:
        model = CardRuling
        fields = [
            "id",
            "ruling_text",
            "published_at",
            "source",
            "card",
        ]
        read_only_fields = ["id"]


class CardAbilitySerializer(serializers.ModelSerializer):
    class Meta:
        model = CardAbility
        fields = [
            "id",
            "ability_type",
            "keyword",
            "ability_text",
            "timing",
            "card",
        ]
        read_only_fields = ["id"]


class DeckSerializer(serializers.ModelSerializer):
    class Meta:
        model = Deck
        fields = [
            "id",
            "name",
            "description",
            "format",
            "is_public",
            "is_tournament_legal",
            "archetype",
            "wins",
            "losses",
            "created_at",
            "updated_at",
            "player",
            "cards",
            "sideboard_cards",
            "tags",
        ]
        read_only_fields = ["id"]


class DeckCardSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeckCard
        fields = [
            "id",
            "quantity",
            "is_commander",
            "deck",
            "card",
        ]
        read_only_fields = ["id"]


class DeckSideboardCardSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeckSideboardCard
        fields = [
            "id",
            "quantity",
            "deck",
            "card",
        ]
        read_only_fields = ["id"]


class DeckTagSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeckTag
        fields = [
            "id",
            "name",
            "color",
        ]
        read_only_fields = ["id"]


class DeckTagAssignmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeckTagAssignment
        fields = [
            "id",
            "deck",
            "tag",
        ]
        read_only_fields = ["id"]
