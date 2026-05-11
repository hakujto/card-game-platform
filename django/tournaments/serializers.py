from rest_framework import serializers
from .models import Season, Tournament, TournamentJudge, TournamentRegistration, TournamentRound, Match, Game, TournamentPrize, AwardedPrize


class SeasonSerializer(serializers.ModelSerializer):
    class Meta:
        model = Season
        fields = [
            "id",
            "name",
            "start_date",
            "end_date",
            "format",
            "is_active",
            "reward_description",
        ]
        read_only_fields = ["id"]


class TournamentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Tournament
        fields = [
            "id",
            "name",
            "description",
            "format",
            "tournament_type",
            "status",
            "max_players",
            "entry_fee",
            "prize_pool",
            "start_time",
            "end_time",
            "is_online",
            "location",
            "rules_text",
            "created_at",
            "season",
            "organizer",
            "judges",
        ]
        read_only_fields = ["id"]


class TournamentJudgeSerializer(serializers.ModelSerializer):
    class Meta:
        model = TournamentJudge
        fields = [
            "id",
            "role",
            "tournament",
            "player",
        ]
        read_only_fields = ["id"]


class TournamentRegistrationSerializer(serializers.ModelSerializer):
    class Meta:
        model = TournamentRegistration
        fields = [
            "id",
            "status",
            "seed",
            "final_standing",
            "points_earned",
            "registered_at",
            "tournament",
            "player",
            "deck",
        ]
        read_only_fields = ["id"]


class TournamentRoundSerializer(serializers.ModelSerializer):
    class Meta:
        model = TournamentRound
        fields = [
            "id",
            "round_number",
            "status",
            "started_at",
            "ended_at",
            "time_limit_minutes",
            "tournament",
        ]
        read_only_fields = ["id"]


class MatchSerializer(serializers.ModelSerializer):
    class Meta:
        model = Match
        fields = [
            "id",
            "table_number",
            "status",
            "player1_wins",
            "player2_wins",
            "started_at",
            "ended_at",
            "result_notes",
            "round",
            "player1",
            "player2",
        ]
        read_only_fields = ["id"]


class GameSerializer(serializers.ModelSerializer):
    class Meta:
        model = Game
        fields = [
            "id",
            "game_number",
            "winner_side",
            "turns_played",
            "duration_seconds",
            "ended_by",
            "replay_url",
            "match",
            "winner",
        ]
        read_only_fields = ["id"]


class TournamentPrizeSerializer(serializers.ModelSerializer):
    class Meta:
        model = TournamentPrize
        fields = [
            "id",
            "placement_from",
            "placement_to",
            "prize_type",
            "amount",
            "description",
            "packs_count",
            "season_points",
            "tournament",
        ]
        read_only_fields = ["id"]


class AwardedPrizeSerializer(serializers.ModelSerializer):
    class Meta:
        model = AwardedPrize
        fields = [
            "id",
            "final_placement",
            "awarded_at",
            "claimed",
            "claimed_at",
            "prize",
            "player",
        ]
        read_only_fields = ["id"]
