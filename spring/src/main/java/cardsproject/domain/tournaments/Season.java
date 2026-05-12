package cardsproject.domain.tournaments;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "seasons")
public class Season {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name = "";
    private LocalDate startDate;
    private LocalDate endDate;
    @Enumerated(EnumType.STRING)
    private SeasonFormatType format;
    private Boolean isActive = false;
    private String rewardDescription;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }
    public SeasonFormatType getFormat() { return format; }
    public void setFormat(SeasonFormatType format) { this.format = format; }
    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }
    public String getRewardDescription() { return rewardDescription; }
    public void setRewardDescription(String rewardDescription) { this.rewardDescription = rewardDescription; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void activate() {
        throw new UnsupportedOperationException("activate not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void deactivate() {
        throw new UnsupportedOperationException("deactivate not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void finalizeRewards() {
        throw new UnsupportedOperationException("finalizeRewards not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Boolean isOngoing() {
        throw new UnsupportedOperationException("isOngoing not implemented");
    }
}
