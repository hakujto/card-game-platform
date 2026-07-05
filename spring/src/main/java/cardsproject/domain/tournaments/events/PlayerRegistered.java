package cardsproject.domain.tournaments.events;

import org.springframework.context.ApplicationEvent;
import java.time.LocalDateTime;

public class PlayerRegistered extends ApplicationEvent {

    private final Integer tournamentId;
    private final Integer playerId;
    private final LocalDateTime registeredAt;

    public PlayerRegistered(Object source, Integer tournamentId, Integer playerId, LocalDateTime registeredAt) {
        super(source);
        this.tournamentId = tournamentId;
        this.playerId = playerId;
        this.registeredAt = registeredAt;
    }

    public Integer getTournamentId() { return tournamentId; }

    public Integer getPlayerId() { return playerId; }

    public LocalDateTime getRegisteredAt() { return registeredAt; }
}
