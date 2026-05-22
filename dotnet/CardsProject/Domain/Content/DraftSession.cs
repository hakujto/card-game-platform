using CardsProject.Domain.Cards;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace CardsProject.Domain.Content;

public enum DraftSessionStatusType
{
    WaitingForPlayers,
    Drafting,
    Completed,
    Abandoned
}

public enum DraftSessionDraftTypeType
{
    Booster,
    Cube,
    Rochester
}

public class DraftSession : IValidatableObject
{
    public int Id { get; set; }

    public DraftSessionStatusType Status { get; set; }
    public DraftSessionDraftTypeType DraftType { get; set; }
    public int Seats { get; set; } = 8;
    public int TimePerPickSeconds { get; set; } = 30;
    [JsonPropertyName("createdAt")]
    public DateTime? CreatedAt { get; set; } = null;
    [JsonPropertyName("completedAt")]
    public DateTime? CompletedAt { get; set; } = null;

    public int? CardSetId { get; set; }
    [ForeignKey(nameof(CardSetId))]
    public CardSet? CardSet { get; set; }

    // Business operations

    public void Start()
    {
        // TODO: implement start
    }

    public void Abandon()
    {
        // TODO: implement abandon
    }

    public void Complete()
    {
        // TODO: implement complete
    }

    public bool IsFull()
    {
        // TODO: implement is_full
        return default;
    }

    // ── Lifecycle state machine ──────────────────────────────────────
    private static readonly System.Collections.Generic.Dictionary<DraftSessionStatusType, DraftSessionStatusType[]> AllowedTransitions = new()
    {
        [DraftSessionStatusType.WaitingForPlayers] = new[] { DraftSessionStatusType.Drafting, DraftSessionStatusType.Abandoned },
        [DraftSessionStatusType.Drafting] = new[] { DraftSessionStatusType.Completed, DraftSessionStatusType.Abandoned }
    };

    public void AssertTransition(DraftSessionStatusType to)
    {
        if (!AllowedTransitions.TryGetValue(Status, out var allowed) || !System.Array.Exists(allowed, s => s == to))
            throw new InvalidOperationException($"Transition {Status} -> {to} not allowed");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( Seats >= 2 && Seats <= 16 ))
            yield return new ValidationResult("Draft session must have between 2 and 16 seats", new[] { nameof(Id) });
        if (!( TimePerPickSeconds > 0 ))
            yield return new ValidationResult("Time per pick must be greater than zero", new[] { nameof(Id) });
    }
}
