namespace CardsProject.Controllers.Tournaments;

public class TournamentRoundDto
{
    public int? RoundNumber { get; set; }
    public string? Status { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("startedAt")]
    public DateTime? StartedAt { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("endedAt")]
    public DateTime? EndedAt { get; set; }
    public int? TimeLimitMinutes { get; set; }
    public int? TournamentId { get; set; }
}
