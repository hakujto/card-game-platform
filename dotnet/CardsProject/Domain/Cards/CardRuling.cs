using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Cards;

public class CardRuling
{
    public int Id { get; set; }

    public string RulingText { get; set; } = "";
    public DateOnly? PublishedAt { get; set; } = null;
    public string Source { get; set; } = "";

    public int? CardId { get; set; }
    [ForeignKey(nameof(CardId))]
    public Card? Card { get; set; }

    // Business operations

    public bool IsCurrent()
    {
        throw new NotImplementedException("is_current not implemented");
    }

    public bool SupersedesPrevious()
    {
        throw new NotImplementedException("supersedes_previous not implemented");
    }
}
