using CardsProject.Domain.Cards;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Content;

public class DraftPick
{
    public int Id { get; set; }

    public int PickNumber { get; set; } = 0;
    public int PackNumber { get; set; } = 0;
    public DateTime? PickedAt { get; set; } = null;

    public int? ParticipantId { get; set; }
    [ForeignKey(nameof(ParticipantId))]
    public DraftParticipant? Participant { get; set; }
    public int? CardId { get; set; }
    [ForeignKey(nameof(CardId))]
    public Card? Card { get; set; }

    // Business operations

    public bool IsFirstPick()
    {
        throw new NotImplementedException("is_first_pick not implemented");
    }
}
