from rest_framework import serializers
from .models import Season, Tournament, TournamentJudge, TournamentRegistration, TournamentRound, Match, Game, TournamentPrize, AwardedPrize
from players.models import Player


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
    createdAt = serializers.DateTimeField(source="created_at")
    startTime = serializers.DateTimeField(source="start_time")
    endTime = serializers.DateTimeField(source="end_time", required=False, allow_null=True)
    class Meta:
        model = Tournament
        fields = [
            "id",
            "public_id",
            "name",
            "description",
            "status",
            "bracket_data",
            "format",
            "tournament_type",
            "max_players",
            "entry_fee",
            "prize_pool",
            "startTime",
            "endTime",
            "is_online",
            "location",
            "rules_text",
            "createdAt",
            "season",
            "organizer",
            "judges",
        ]
        read_only_fields = ["id"]

    def get_fields(self):
        fields = super().get_fields()
        request = self.context.get("request")
        if request and request.method == "PATCH":
            if "status" in fields: fields["status"].read_only = True
            if "created_at" in fields: fields["created_at"].read_only = True
        return fields


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
    registeredAt = serializers.DateTimeField(source="registered_at")
    class Meta:
        model = TournamentRegistration
        fields = [
            "id",
            "status",
            "seed",
            "final_standing",
            "points_earned",
            "registeredAt",
            "tournament",
            "player",
            "deck",
        ]
        read_only_fields = ["id"]


class TournamentRoundSerializer(serializers.ModelSerializer):
    startedAt = serializers.DateTimeField(source="started_at", required=False, allow_null=True)
    endedAt = serializers.DateTimeField(source="ended_at", required=False, allow_null=True)
    class Meta:
        model = TournamentRound
        fields = [
            "id",
            "round_number",
            "status",
            "startedAt",
            "endedAt",
            "time_limit_minutes",
            "tournament",
        ]
        read_only_fields = ["id"]


class MatchPlayer1Serializer(serializers.ModelSerializer):
    class Meta:
        model = Player
        fields = ["id", "display_name"]


class MatchPlayer2Serializer(serializers.ModelSerializer):
    class Meta:
        model = Player
        fields = ["id", "display_name"]


class MatchSerializer(serializers.ModelSerializer):
    player1_data = MatchPlayer1Serializer(source="player1", read_only=True)
    player1 = serializers.PrimaryKeyRelatedField(queryset=Player.objects.all())
    player2_data = MatchPlayer2Serializer(source="player2", read_only=True)
    player2 = serializers.PrimaryKeyRelatedField(queryset=Player.objects.all(), required=False, allow_null=True)
    startedAt = serializers.DateTimeField(source="started_at", required=False, allow_null=True)
    endedAt = serializers.DateTimeField(source="ended_at", required=False, allow_null=True)
    class Meta:
        model = Match
        fields = [
            "id",
            "table_number",
            "status",
            "player1_wins",
            "player2_wins",
            "startedAt",
            "endedAt",
            "result_notes",
            "round",
            "player1",
            "player2",
            "player1_data",
            "player2_data",
        ]
        read_only_fields = ["id"]


class GameSerializer(serializers.ModelSerializer):
    class Meta:
        model = Game
        fields = [
            "id",
            "game_number",
            "winner_side",
            "complexity_score",
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
    awardedAt = serializers.DateTimeField(source="awarded_at")
    claimedAt = serializers.DateTimeField(source="claimed_at", required=False, allow_null=True)
    class Meta:
        model = AwardedPrize
        fields = [
            "id",
            "final_placement",
            "awardedAt",
            "claimed",
            "claimedAt",
            "prize",
            "player",
        ]
        read_only_fields = ["id"]

    def get_fields(self):
        fields = super().get_fields()
        request = self.context.get("request")
        if request and request.method == "PATCH":
            if "final_placement" in fields: fields["final_placement"].read_only = True
            if "awarded_at" in fields: fields["awarded_at"].read_only = True
        return fields
