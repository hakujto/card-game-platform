using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Content;

public class DraftParticipant
{
    public int Id { get; set; }

    public int SeatNumber { get; set; } = 0;
    public DateTime? JoinedAt { get; set; } = null;

    public int? SessionId { get; set; }
    [ForeignKey(nameof(SessionId))]
    public DraftSession? Session { get; set; }
    public int? PlayerId { get; set; }
    [ForeignKey(nameof(PlayerId))]
    public Player? Player { get; set; }

    // Business operations

    public void PickCard(int cardId, int packNumber)
    {
        throw new NotImplementedException("pick_card not implemented");
    }

    public int DraftedCardCount()
    {
        throw new NotImplementedException("drafted_card_count not implemented");
    }
}
