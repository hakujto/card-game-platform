package cardsproject.domain.players;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "player_collections")
public class PlayerCollection {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer quantity = 1;
    private Boolean foil = false;
    @Enumerated(EnumType.STRING)
    private PlayerCollectionConditionType condition;
    private LocalDateTime acquiredAt;
    @Enumerated(EnumType.STRING)
    private PlayerCollectionAcquiredViaType acquiredVia;

    @Column(name = "player_id")
    private Long playerId;
    @Column(name = "card_id")
    private Long cardId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public Boolean getFoil() { return foil; }
    public void setFoil(Boolean foil) { this.foil = foil; }
    public PlayerCollectionConditionType getCondition() { return condition; }
    public void setCondition(PlayerCollectionConditionType condition) { this.condition = condition; }
    public LocalDateTime getAcquiredAt() { return acquiredAt; }
    public void setAcquiredAt(LocalDateTime acquiredAt) { this.acquiredAt = acquiredAt; }
    public PlayerCollectionAcquiredViaType getAcquiredVia() { return acquiredVia; }
    public void setAcquiredVia(PlayerCollectionAcquiredViaType acquiredVia) { this.acquiredVia = acquiredVia; }
    public Long getPlayerId() { return playerId; }
    public void setPlayerId(Long playerId) { this.playerId = playerId; }
    public Long getCardId() { return cardId; }
    public void setCardId(Long cardId) { this.cardId = cardId; }
}
