using CardsProject.Domain.Cards;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Players;

public enum PlayerCollectionConditionType
{
    Mint,
    NearMint,
    Excellent,
    Good,
    Played
}

public enum PlayerCollectionAcquiredViaType
{
    Purchase,
    Trade,
    TournamentReward,
    Pack,
    Craft
}

public class PlayerCollection : IValidatableObject
{
    public int Id { get; set; }

    public int Quantity { get; set; } = 1;
    public bool Foil { get; set; } = false;
    public PlayerCollectionConditionType Condition { get; set; }
    public DateTime? AcquiredAt { get; set; } = null;
    public PlayerCollectionAcquiredViaType AcquiredVia { get; set; }

    public int? PlayerId { get; set; }
    [ForeignKey(nameof(PlayerId))]
    public Player? Player { get; set; }
    public int? CardId { get; set; }
    [ForeignKey(nameof(CardId))]
    public Card? Card { get; set; }

    // Business operations

    public void Add(int quantity)
    {
        throw new NotImplementedException("add not implemented");
    }

    public void Remove(int quantity)
    {
        throw new NotImplementedException("remove not implemented");
    }

    public decimal EstimatedValue()
    {
        throw new NotImplementedException("estimated_value not implemented");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( Quantity > 0 ))
            yield return new ValidationResult("Collection quantity must be greater than zero", new[] { nameof(Id) });
    }
}
