package cardsproject.domain.tournaments;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "tournament_rounds")
public class TournamentRound {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer roundNumber = 0;
    @Enumerated(EnumType.STRING)
    private TournamentRoundStatusType status;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
    private Integer timeLimitMinutes = 50;

    @Column(name = "tournament_id")
    private Long tournamentId;
    @Column(name = "matches_id")
    private Long matchesId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Integer getRoundNumber() { return roundNumber; }
    public void setRoundNumber(Integer roundNumber) { this.roundNumber = roundNumber; }
    public TournamentRoundStatusType getStatus() { return status; }
    public void setStatus(TournamentRoundStatusType status) { this.status = status; }
    public LocalDateTime getStartedAt() { return startedAt; }
    public void setStartedAt(LocalDateTime startedAt) { this.startedAt = startedAt; }
    public LocalDateTime getEndedAt() { return endedAt; }
    public void setEndedAt(LocalDateTime endedAt) { this.endedAt = endedAt; }
    public Integer getTimeLimitMinutes() { return timeLimitMinutes; }
    public void setTimeLimitMinutes(Integer timeLimitMinutes) { this.timeLimitMinutes = timeLimitMinutes; }
    public Long getTournamentId() { return tournamentId; }
    public void setTournamentId(Long tournamentId) { this.tournamentId = tournamentId; }
    public Long getMatchesId() { return matchesId; }
    public void setMatchesId(Long matchesId) { this.matchesId = matchesId; }
}
