package cardsproject.domain.tournaments;

import jakarta.persistence.*;

@Entity
@Table(name = "tournament_judges")
public class TournamentJudge {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private TournamentJudgeRoleType role;

    @Column(name = "tournament_id")
    private Long tournamentId;
    @Column(name = "player_id")
    private Long playerId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public TournamentJudgeRoleType getRole() { return role; }
    public void setRole(TournamentJudgeRoleType role) { this.role = role; }
    public Long getTournamentId() { return tournamentId; }
    public void setTournamentId(Long tournamentId) { this.tournamentId = tournamentId; }
    public Long getPlayerId() { return playerId; }
    public void setPlayerId(Long playerId) { this.playerId = playerId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void promoteToHead() {
        throw new UnsupportedOperationException("promoteToHead not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void remove() {
        throw new UnsupportedOperationException("remove not implemented");
    }
}
