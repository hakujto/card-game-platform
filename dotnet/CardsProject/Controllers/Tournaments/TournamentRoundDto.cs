namespace CardsProject.Controllers.Tournaments;

public class TournamentRoundDto
{
    public int? RoundNumber { get; set; }
    public string? Status { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? EndedAt { get; set; }
    public int? TimeLimitMinutes { get; set; }
    public int? TournamentId { get; set; }
    public int? MatchesId { get; set; }
}
