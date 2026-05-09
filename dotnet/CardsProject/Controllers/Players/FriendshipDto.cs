namespace CardsProject.Controllers.Players;

public class FriendshipDto
{
    public string? Status { get; set; }
    public DateTime? CreatedAt { get; set; }
    public int? RequesterId { get; set; }
    public int? ReceiverId { get; set; }
}
