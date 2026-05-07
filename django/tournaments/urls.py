from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import SeasonViewSet, TournamentViewSet, TournamentJudgeViewSet, TournamentRegistrationViewSet, TournamentRoundViewSet, MatchViewSet, GameViewSet, TournamentPrizeViewSet, AwardedPrizeViewSet

router = DefaultRouter()
router.register(r"seasons", SeasonViewSet, basename="season")
router.register(r"tournaments", TournamentViewSet, basename="tournament")
router.register(r"tournament_judges", TournamentJudgeViewSet, basename="tournament_judge")
router.register(r"tournament_registrations", TournamentRegistrationViewSet, basename="tournament_registration")
router.register(r"tournament_rounds", TournamentRoundViewSet, basename="tournament_round")
router.register(r"matches", MatchViewSet, basename="match")
router.register(r"games", GameViewSet, basename="game")
router.register(r"tournament_prizes", TournamentPrizeViewSet, basename="tournament_prize")
router.register(r"awarded_prizes", AwardedPrizeViewSet, basename="awarded_prize")

urlpatterns = [
    path("", include(router.urls)),
]
