using CardsProject.Domain.Cards;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Players;

public class CraftingRecipe
{
    public int Id { get; set; }

    public int DustCost { get; set; } = 0;
    public bool IsAvailable { get; set; } = true;

    public int? ResultCardId { get; set; }
    [ForeignKey(nameof(ResultCardId))]
    public Card? ResultCard { get; set; }

    public ICollection<Card> RequiredCards { get; set; } = new List<Card>();
}
