from rest_framework import serializers
from .models import Card, CardSet, CardRuling, CardAbility, Deck, DeckCard, DeckSideboardCard, DeckTag, DeckTagAssignment
from players.models import Player


class CardSerializer(serializers.ModelSerializer):
    class Meta:
        model = Card
        fields = [
            "id",
            "public_id",
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
            "metadata",
            "total_copies_in_circulation",
            "set",
        ]
        read_only_fields = ["id"]

    def get_fields(self):
        fields = super().get_fields()
        request = self.context.get("request")
        if request and request.method == "PATCH":
            if "is_banned" in fields: fields["is_banned"].read_only = True
            if "is_restricted" in fields: fields["is_restricted"].read_only = True
        return fields


class CardSetSerializer(serializers.ModelSerializer):
    class Meta:
        model = CardSet
        fields = [
            "id",
            "name",
            "code",
            "release_date",
            "rotation_date",
            "set_type",
            "total_cards",
            "is_rotated",
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


class DeckPlayerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Player
        fields = ["id", "display_name", "avatar_url"]


class DeckSerializer(serializers.ModelSerializer):
    player_data = DeckPlayerSerializer(source="player", read_only=True)
    player = serializers.PrimaryKeyRelatedField(queryset=Player.objects.all())
    createdAt = serializers.DateTimeField(source="created_at")
    updatedAt = serializers.DateTimeField(source="updated_at")
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
            "draws",
            "createdAt",
            "updatedAt",
            "player",
            "cards",
            "sideboard_cards",
            "tags",
            "player_data",
        ]
        read_only_fields = ["id"]

    def get_fields(self):
        fields = super().get_fields()
        request = self.context.get("request")
        if request and request.method == "PATCH":
            if "wins" in fields: fields["wins"].read_only = True
            if "losses" in fields: fields["losses"].read_only = True
            if "draws" in fields: fields["draws"].read_only = True
            if "created_at" in fields: fields["created_at"].read_only = True
        return fields


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
            "slug",
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
