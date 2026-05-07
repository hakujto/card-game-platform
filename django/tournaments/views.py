from rest_framework import viewsets, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Season, Tournament, TournamentJudge, TournamentRegistration, TournamentRound, Match, Game, TournamentPrize, AwardedPrize
from .serializers import SeasonSerializer, TournamentSerializer, TournamentJudgeSerializer, TournamentRegistrationSerializer, TournamentRoundSerializer, MatchSerializer, GameSerializer, TournamentPrizeSerializer, AwardedPrizeSerializer


class SeasonViewSet(viewsets.ModelViewSet):
    queryset = Season.objects.all()
    serializer_class = SeasonSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "format", "reward_description"]
    filterset_fields = ["format"]


class TournamentViewSet(viewsets.ModelViewSet):
    queryset = Tournament.objects.all()
    serializer_class = TournamentSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["name", "description", "format"]
    filterset_fields = ["format", "tournament_type", "status", "season", "organizer"]


class TournamentJudgeViewSet(viewsets.ModelViewSet):
    queryset = TournamentJudge.objects.all()
    serializer_class = TournamentJudgeSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["role"]
    filterset_fields = ["role", "tournament", "player"]


class TournamentRegistrationViewSet(viewsets.ModelViewSet):
    queryset = TournamentRegistration.objects.all()
    serializer_class = TournamentRegistrationSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status"]
    filterset_fields = ["status", "tournament", "player", "deck"]


class TournamentRoundViewSet(viewsets.ModelViewSet):
    queryset = TournamentRound.objects.all()
    serializer_class = TournamentRoundSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status"]
    filterset_fields = ["status", "tournament", "matches"]


class MatchViewSet(viewsets.ModelViewSet):
    queryset = Match.objects.all()
    serializer_class = MatchSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["status", "result_notes"]
    filterset_fields = ["status", "round", "player1", "player2", "games"]


class GameViewSet(viewsets.ModelViewSet):
    queryset = Game.objects.all()
    serializer_class = GameSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["winner_side", "ended_by"]
    filterset_fields = ["winner_side", "ended_by", "match", "winner"]


class TournamentPrizeViewSet(viewsets.ModelViewSet):
    queryset = TournamentPrize.objects.all()
    serializer_class = TournamentPrizeSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ["prize_type", "description"]
    filterset_fields = ["prize_type", "tournament"]


class AwardedPrizeViewSet(viewsets.ModelViewSet):
    queryset = AwardedPrize.objects.all()
    serializer_class = AwardedPrizeSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ["prize", "player"]
