using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace CardsProject.Domain.Cards;

public enum DeckFormatType
{
    Standard,
    Extended,
    Legacy,
    Vintage,
    Commander,
    Draft
}

public enum DeckArchetypeType
{
    Aggro,
    Control,
    Midrange,
    Combo,
    Prison,
    Tempo
}

public class Deck : IValidatableObject
{
    public int Id { get; set; }

    public string Name { get; set; } = "";
    public string? Description { get; set; }
    public DeckFormatType Format { get; set; }
    public bool IsPublic { get; set; } = false;
    public bool IsTournamentLegal { get; set; } = false;
    public DeckArchetypeType? Archetype { get; set; }
    public int Wins { get; set; } = 0;
    public int Losses { get; set; } = 0;
    public int Draws { get; set; } = 0;
    public DateTime? CreatedAt { get; set; } = null;
    public DateTime? UpdatedAt { get; set; } = null;

    public int? PlayerId { get; set; }
    [ForeignKey(nameof(PlayerId))]
    public Player? Player { get; set; }

    public ICollection<Card> Cards { get; set; } = new List<Card>();
    public ICollection<Card> SideboardCards { get; set; } = new List<Card>();
    public ICollection<DeckTag> Tags { get; set; } = new List<DeckTag>();

    // Business operations

    public bool ValidateSize()
    {
        throw new NotImplementedException("validate_size not implemented");
    }

    public void AddCard(int cardId, int quantity)
    {
        throw new NotImplementedException("add_card not implemented");
    }

    public void RemoveCard(int cardId)
    {
        throw new NotImplementedException("remove_card not implemented");
    }

    public decimal WinRate()
    {
        throw new NotImplementedException("win_rate not implemented");
    }

    public object Clone()
    {
        throw new NotImplementedException("clone not implemented");
    }

    public void Publish()
    {
        throw new NotImplementedException("publish not implemented");
    }

    public void Unpublish()
    {
        throw new NotImplementedException("unpublish not implemented");
    }

    public bool CertifyTournamentLegal()
    {
        throw new NotImplementedException("certify_tournament_legal not implemented");
    }

    // ── Domain invariants (simple rules) ──────────────────────────────
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (!( Wins >= 0 ))
            yield return new ValidationResult("Deck wins count must not be negative", new[] { nameof(Id) });
        if (!( Losses >= 0 ))
            yield return new ValidationResult("Deck losses count must not be negative", new[] { nameof(Id) });
        if (!( Draws >= 0 ))
            yield return new ValidationResult("Deck draws count must not be negative", new[] { nameof(Id) });
    }
}
