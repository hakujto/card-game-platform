namespace CardsProject.Controllers.Tournaments;

public class GameDto
{
    public int? GameNumber { get; set; }
    public string? WinnerSide { get; set; }
    public int? TurnsPlayed { get; set; }
    public int? DurationSeconds { get; set; }
    public string? EndedBy { get; set; }
    public string? ReplayUrl { get; set; }
    public int? MatchId { get; set; }
    public int? WinnerId { get; set; }
}
