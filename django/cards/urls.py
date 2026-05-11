from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .viewsets import CardViewSet, CardSetViewSet, CardRulingViewSet, CardAbilityViewSet, DeckViewSet, DeckCardViewSet, DeckSideboardCardViewSet, DeckTagViewSet, DeckTagAssignmentViewSet

router = DefaultRouter()
router.register(r"cards", CardViewSet, basename="card")
router.register(r"card_sets", CardSetViewSet, basename="card_set")
router.register(r"card_rulings", CardRulingViewSet, basename="card_ruling")
router.register(r"card_abilities", CardAbilityViewSet, basename="card_ability")
router.register(r"decks", DeckViewSet, basename="deck")
router.register(r"deck_cards", DeckCardViewSet, basename="deck_card")
router.register(r"deck_sideboard_cards", DeckSideboardCardViewSet, basename="deck_sideboard_card")
router.register(r"deck_tags", DeckTagViewSet, basename="deck_tag")
router.register(r"deck_tag_assignments", DeckTagAssignmentViewSet, basename="deck_tag_assignment")

urlpatterns = [
    path("", include(router.urls)),
]
