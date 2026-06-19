package cardsproject.domain.players;

import jakarta.persistence.*;

@Entity
@Table(name = "crafting_recipes")
public class CraftingRecipe {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer dustCost = 0;
    private Boolean isAvailable = true;

    // @ManyToOne -> Card, onDelete=PROTECT, relatedName=crafting_recipes, via=cards
    @Column(name = "result_card_id")
    private Long resultCardId;

    // M2M: required_cards -> Card, represented via CraftingIngredient entity (through model); no direct field here

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getDustCost() { return dustCost; }
    public void setDustCost(Integer dustCost) { this.dustCost = dustCost; }
    public Boolean getIsAvailable() { return isAvailable; }
    public void setIsAvailable(Boolean isAvailable) { this.isAvailable = isAvailable; }
    public Long getResultCardId() { return resultCardId; }
    public void setResultCardId(Long resultCardId) { this.resultCardId = resultCardId; }

    // ── Business operations ──────────────────────────────────────────
    public Boolean canCraft(Integer playerId) {
        // TODO: implement canCraft
        return null;
    }
    public void executeCraft(Integer playerId) {
        // TODO: implement executeCraft
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void disable() {
        // TODO: implement disable
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void enable() {
        // TODO: implement enable
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Crafting recipe must have a dust cost greater than zero")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isDustCostPositiveValid() {
        return (getDustCost() == null || getDustCost() > 0);
    }
}
