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

    @Column(name = "result_card_id")
    private Long resultCardId;

    // M2M: required_cards managed via join table

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getDustCost() { return dustCost; }
    public void setDustCost(Integer dustCost) { this.dustCost = dustCost; }
    public Boolean getIsAvailable() { return isAvailable; }
    public void setIsAvailable(Boolean isAvailable) { this.isAvailable = isAvailable; }
    public Long getResultCardId() { return resultCardId; }
    public void setResultCardId(Long resultCardId) { this.resultCardId = resultCardId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void disable() {
        throw new UnsupportedOperationException("disable not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void enable() {
        throw new UnsupportedOperationException("enable not implemented");
    }
}
