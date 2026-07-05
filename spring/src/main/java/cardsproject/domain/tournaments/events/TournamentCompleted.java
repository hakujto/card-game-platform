package cardsproject.domain.tournaments.events;

import org.springframework.context.ApplicationEvent;
import java.time.LocalDateTime;

public class TournamentCompleted extends ApplicationEvent {

    private final Integer tournamentId;
    private final Integer seasonId;
    private final LocalDateTime completedAt;

    public TournamentCompleted(Object source, Integer tournamentId, Integer seasonId, LocalDateTime completedAt) {
        super(source);
        this.tournamentId = tournamentId;
        this.seasonId = seasonId;
        this.completedAt = completedAt;
    }

    public Integer getTournamentId() { return tournamentId; }

    public Integer getSeasonId() { return seasonId; }

    public LocalDateTime getCompletedAt() { return completedAt; }
}
