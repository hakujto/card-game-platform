namespace CardsProject.Controllers.Tournaments;

public class MatchDto
{
    public int? TableNumber { get; set; }
    public string? Status { get; set; }
    public int? Player1Wins { get; set; }
    public int? Player2Wins { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("startedAt")]
    public DateTime? StartedAt { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("endedAt")]
    public DateTime? EndedAt { get; set; }
    public string? ResultNotes { get; set; }
    public int? RoundId { get; set; }
    public int? Player1Id { get; set; }
    public int? Player2Id { get; set; }
}
