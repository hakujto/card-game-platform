namespace CardsProject.Controllers.Players;

public class PlayerSeasonStatsDto
{
    public int? Wins { get; set; }
    public int? Losses { get; set; }
    public int? Draws { get; set; }
    public int? TournamentWins { get; set; }
    public string? HighestRank { get; set; }
    public int? SeasonPoints { get; set; }
    public int? PlayerId { get; set; }
    public int? SeasonId { get; set; }
}
