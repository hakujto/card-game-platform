namespace CardsProject.Controllers.Players;

public class FriendshipDto
{
    public string? Status { get; set; }
    [System.Text.Json.Serialization.JsonPropertyName("createdAt")]
    public DateTime? CreatedAt { get; set; }
    public int? RequesterId { get; set; }
    public int? ReceiverId { get; set; }
}
