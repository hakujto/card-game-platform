package cardsproject.domain.players;

import jakarta.persistence.*;

@Entity
@Table(name = "crafting_ingredients")
public class CraftingIngredient {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer quantity = 1;

    // @ManyToOne -> CraftingRecipe, onDelete=CASCADE, relatedName=ingredients
    @Column(name = "recipe_id")
    private Long recipeId;
    // @ManyToOne -> Card, onDelete=PROTECT, relatedName=used_in_recipes, via=cards
    @Column(name = "card_id")
    private Long cardId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public Long getRecipeId() { return recipeId; }
    public void setRecipeId(Long recipeId) { this.recipeId = recipeId; }
    public Long getCardId() { return cardId; }
    public void setCardId(Long cardId) { this.cardId = cardId; }
}
