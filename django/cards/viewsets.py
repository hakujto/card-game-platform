from rest_framework import viewsets, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Card, CardSet, CardRuling, CardAbility, Deck, DeckCard, DeckSideboardCard, DeckTag, DeckTagAssignment
from .serializers import CardSerializer, CardSetSerializer, CardRulingSerializer, CardAbilitySerializer, DeckSerializer, DeckCardSerializer, DeckSideboardCardSerializer, DeckTagSerializer, DeckTagAssignmentSerializer


class CardViewSet(viewsets.ModelViewSet):
    queryset = Card.objects.select_related().all()
    serializer_class = CardSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "card_type", "rarity"]
    filterset_fields = ["card_type", "rarity", "mana_colors", "legal_formats", "set"]
    ordering_fields = "__all__"


class CardSetViewSet(viewsets.ModelViewSet):
    queryset = CardSet.objects.select_related().all()
    serializer_class = CardSetSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "code", "set_type"]
    filterset_fields = ["set_type"]
    ordering_fields = "__all__"


class CardRulingViewSet(viewsets.ModelViewSet):
    queryset = CardRuling.objects.select_related().all()
    serializer_class = CardRulingSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["ruling_text", "source"]
    filterset_fields = ["card"]
    ordering_fields = "__all__"


class CardAbilityViewSet(viewsets.ModelViewSet):
    queryset = CardAbility.objects.select_related().all()
    serializer_class = CardAbilitySerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["ability_type", "keyword", "ability_text"]
    filterset_fields = ["ability_type", "timing", "card"]
    ordering_fields = "__all__"


class DeckViewSet(viewsets.ModelViewSet):
    queryset = Deck.objects.select_related().all()
    serializer_class = DeckSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "description", "format"]
    filterset_fields = ["format", "archetype", "player"]
    ordering_fields = "__all__"


class DeckCardViewSet(viewsets.ModelViewSet):
    queryset = DeckCard.objects.select_related().all()
    serializer_class = DeckCardSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["deck", "card"]
    ordering_fields = "__all__"


class DeckSideboardCardViewSet(viewsets.ModelViewSet):
    queryset = DeckSideboardCard.objects.select_related().all()
    serializer_class = DeckSideboardCardSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["deck", "card"]
    ordering_fields = "__all__"


class DeckTagViewSet(viewsets.ModelViewSet):
    queryset = DeckTag.objects.select_related().all()
    serializer_class = DeckTagSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "color"]
    ordering_fields = "__all__"


class DeckTagAssignmentViewSet(viewsets.ModelViewSet):
    queryset = DeckTagAssignment.objects.select_related().all()
    serializer_class = DeckTagAssignmentSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["deck", "tag"]
    ordering_fields = "__all__"
