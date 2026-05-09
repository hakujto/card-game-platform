namespace CardsProject.Controllers.Tournaments;

public class TournamentRegistrationDto
{
    public string? Status { get; set; }
    public int? Seed { get; set; }
    public int? FinalStanding { get; set; }
    public int? PointsEarned { get; set; }
    public DateTime? RegisteredAt { get; set; }
    public int? TournamentId { get; set; }
    public int? PlayerId { get; set; }
    public int? DeckId { get; set; }
}
