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
        // TODO: implement is_current
        return default;
    }

    public bool SupersedesPrevious()
    {
        // TODO: implement supersedes_previous
        return default;
    }
}
