namespace CardsProject.Controllers.Content;

public class StreamDto
{
    public string? Title { get; set; }
    public string? StreamUrl { get; set; }
    public string? Status { get; set; }
    public string? Platform { get; set; }
    public string? Language { get; set; }
    public bool? IsOfficial { get; set; }
    public int? ViewerCountPeak { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("scheduledStart")]
    public DateTime? ScheduledStart { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("actualStart")]
    public DateTime? ActualStart { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("endedAt")]
    public DateTime? EndedAt { get; set; }
    public string? VodUrl { get; set; }
    public int? TournamentId { get; set; }
    public int? StreamerId { get; set; }
}
