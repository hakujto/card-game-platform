from django.contrib import admin
from .models import Season, Tournament, TournamentJudge, TournamentRegistration, TournamentRound, Match, Game, TournamentPrize, AwardedPrize


@admin.register(Season)
class SeasonAdmin(admin.ModelAdmin):
    list_display = ["id", "name", "start_date", "end_date", "format"]
    search_fields = ["name", "format", "reward_description"]
    list_filter = ["format"]


@admin.register(Tournament)
class TournamentAdmin(admin.ModelAdmin):
    list_display = ["id", "name", "description", "format", "tournament_type"]
    search_fields = ["name", "description", "format"]
    list_filter = ["format", "tournament_type", "status", "season", "organizer"]


@admin.register(TournamentJudge)
class TournamentJudgeAdmin(admin.ModelAdmin):
    list_display = ["id", "role", "tournament", "player"]
    search_fields = ["role"]
    list_filter = ["role", "tournament", "player"]


@admin.register(TournamentRegistration)
class TournamentRegistrationAdmin(admin.ModelAdmin):
    list_display = ["id", "status", "seed", "final_standing", "points_earned"]
    search_fields = ["status"]
    list_filter = ["status", "tournament", "player", "deck"]


@admin.register(TournamentRound)
class TournamentRoundAdmin(admin.ModelAdmin):
    list_display = ["id", "round_number", "status", "started_at", "ended_at"]
    search_fields = ["status"]
    list_filter = ["status", "tournament"]


@admin.register(Match)
class MatchAdmin(admin.ModelAdmin):
    list_display = ["id", "table_number", "status", "player1_wins", "player2_wins"]
    search_fields = ["status", "result_notes"]
    list_filter = ["status", "round", "player1", "player2"]


@admin.register(Game)
class GameAdmin(admin.ModelAdmin):
    list_display = ["id", "game_number", "winner_side", "turns_played", "duration_seconds"]
    search_fields = ["winner_side", "ended_by"]
    list_filter = ["winner_side", "ended_by", "match", "winner"]


@admin.register(TournamentPrize)
class TournamentPrizeAdmin(admin.ModelAdmin):
    list_display = ["id", "placement_from", "placement_to", "prize_type", "amount"]
    search_fields = ["prize_type", "description"]
    list_filter = ["prize_type", "tournament"]


@admin.register(AwardedPrize)
class AwardedPrizeAdmin(admin.ModelAdmin):
    list_display = ["id", "final_placement", "awarded_at", "claimed", "claimed_at"]
    list_filter = ["prize", "player"]
