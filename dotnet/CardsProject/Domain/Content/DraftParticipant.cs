using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace CardsProject.Domain.Content;

public class DraftParticipant : IValidatableObject
{
    public int Id { get; set; }

    public int SeatNumber { get; set; } = 0;
    [JsonPropertyName("joinedAt")]
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
        // TODO: implement pick_card
    }

    public int DraftedCardCount()
    {
        // TODO: implement drafted_card_count
        return default;
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( SeatNumber > 0 ))
            yield return new ValidationResult("Seat number must be greater than zero", new[] { nameof(Id) });
    }
}
