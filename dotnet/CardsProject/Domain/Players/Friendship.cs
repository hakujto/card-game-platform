using System.ComponentModel.DataAnnotations.Schema;

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
        throw new NotImplementedException("accept not implemented");
    }

    public void Decline()
    {
        throw new NotImplementedException("decline not implemented");
    }

    public void Block()
    {
        throw new NotImplementedException("block not implemented");
    }
}
