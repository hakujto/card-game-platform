namespace CardsProject.Controllers.Tournaments;

public class MatchDto
{
    public int? TableNumber { get; set; }
    public string? Status { get; set; }
    public int? Player1Wins { get; set; }
    public int? Player2Wins { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? EndedAt { get; set; }
    public string? ResultNotes { get; set; }
    public int? RoundId { get; set; }
    public int? Player1Id { get; set; }
    public int? Player2Id { get; set; }
    public int? GamesId { get; set; }
}
