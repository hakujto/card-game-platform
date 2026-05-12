package cardsproject.domain.tournaments;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "tournament_prizes")
public class TournamentPrize {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer placementFrom = 0;
    private Integer placementTo = 0;
    @Enumerated(EnumType.STRING)
    private TournamentPrizePrizeTypeType prizeType;
    private BigDecimal amount = new BigDecimal("0");
    private String description;
    private Integer packsCount;
    private Integer seasonPoints = 0;

    @Column(name = "tournament_id")
    private Long tournamentId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getPlacementFrom() { return placementFrom; }
    public void setPlacementFrom(Integer placementFrom) { this.placementFrom = placementFrom; }
    public Integer getPlacementTo() { return placementTo; }
    public void setPlacementTo(Integer placementTo) { this.placementTo = placementTo; }
    public TournamentPrizePrizeTypeType getPrizeType() { return prizeType; }
    public void setPrizeType(TournamentPrizePrizeTypeType prizeType) { this.prizeType = prizeType; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Integer getPacksCount() { return packsCount; }
    public void setPacksCount(Integer packsCount) { this.packsCount = packsCount; }
    public Integer getSeasonPoints() { return seasonPoints; }
    public void setSeasonPoints(Integer seasonPoints) { this.seasonPoints = seasonPoints; }
    public Long getTournamentId() { return tournamentId; }
    public void setTournamentId(Long tournamentId) { this.tournamentId = tournamentId; }

    // ── Business operations ──────────────────────────────────────────
    public Boolean appliesToPlacement(Integer placement) {
        throw new UnsupportedOperationException("appliesToPlacement not implemented");
    }
}
