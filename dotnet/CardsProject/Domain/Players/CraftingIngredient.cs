using CardsProject.Domain.Cards;
using System.ComponentModel.DataAnnotations.Schema;

namespace CardsProject.Domain.Players;

public class CraftingIngredient
{
    public int Id { get; set; }

    public int Quantity { get; set; } = 1;

    public int? RecipeId { get; set; }
    [ForeignKey(nameof(RecipeId))]
    public CraftingRecipe? Recipe { get; set; }
    public int? CardId { get; set; }
    [ForeignKey(nameof(CardId))]
    public Card? Card { get; set; }
}
