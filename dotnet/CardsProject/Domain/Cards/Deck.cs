using CardsProject.Domain.Players;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

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
    [JsonPropertyName("createdAt")]
    public DateTime? CreatedAt { get; set; } = null;
    [JsonPropertyName("updatedAt")]
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
        // TODO: implement validate_size
        return default;
    }

    public void AddCard(int cardId, int quantity)
    {
        // TODO: implement add_card
    }

    public void RemoveCard(int cardId)
    {
        // TODO: implement remove_card
    }

    public decimal WinRate()
    {
        // TODO: implement win_rate
        return default;
    }

    public object Clone()
    {
        // TODO: implement clone
        return default;
    }

    public void Publish()
    {
        // TODO: implement publish
    }

    public void Unpublish()
    {
        // TODO: implement unpublish
    }

    public bool CertifyTournamentLegal()
    {
        // TODO: implement certify_tournament_legal
        return default;
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

    // ── Lifecycle hooks (call from AppDbContext.SaveChangesAsync override) ───
    public void RecalculateTournamentLegal()
    {
        // TODO: implement recalculate_tournament_legal
    }
}
