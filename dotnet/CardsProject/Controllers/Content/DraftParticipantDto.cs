namespace CardsProject.Controllers.Content;

public class DraftParticipantDto
{
    public int? SeatNumber { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("joinedAt")]
    public DateTime? JoinedAt { get; set; }
    public int? SessionId { get; set; }
    public int? PlayerId { get; set; }
}
