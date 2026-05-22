using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace CardsProject.Domain.Players;

public enum FriendshipStatusType
{
    Pending,
    Accepted,
    Blocked
}

public class Friendship
{
    public int Id { get; set; }

    public FriendshipStatusType Status { get; set; }
    [JsonPropertyName("createdAt")]
    public DateTime? CreatedAt { get; set; } = null;

    public int? RequesterId { get; set; }
    [ForeignKey(nameof(RequesterId))]
    public Player? Requester { get; set; }
    public int? ReceiverId { get; set; }
    [ForeignKey(nameof(ReceiverId))]
    public Player? Receiver { get; set; }

    // Business operations

    public void Accept()
    {
        // TODO: implement accept
    }

    public void Decline()
    {
        // TODO: implement decline
    }

    public void Block()
    {
        // TODO: implement block
    }
}
