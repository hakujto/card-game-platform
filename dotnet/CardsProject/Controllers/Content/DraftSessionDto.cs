namespace CardsProject.Controllers.Content;

public class DraftSessionDto
{
    public string? Status { get; set; }
    public string? DraftType { get; set; }
    public string? PackContents { get; set; }
    public int? Seats { get; set; }
    public int? TimePerPickSeconds { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("createdAt")]
    public DateTime? CreatedAt { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("completedAt")]
    public DateTime? CompletedAt { get; set; }
    public int? CardSetId { get; set; }
}
