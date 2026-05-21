package cardsproject.service.tournaments;

import cardsproject.domain.tournaments.Tournament;
import cardsproject.repository.tournaments.TournamentRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.tournaments.TournamentStatusType;
import cardsproject.domain.tournaments.TournamentFormatType;
import cardsproject.domain.tournaments.TournamentTournamentTypeType;

@Service
public class TournamentService {

    private final TournamentRepository repository;

    public TournamentService(TournamentRepository repository) {
        this.repository = repository;
    }

    public List<Tournament> findAll() {
        return repository.findAll();
    }

    public List<Tournament> search(String q) {
        if (q == null || q.isBlank()) return repository.findAll();
        return repository.findAll().stream()
            .filter(e -> (e.getName() != null && e.getName().toLowerCase().contains(q.toLowerCase())) || (e.getDescription() != null && e.getDescription().toLowerCase().contains(q.toLowerCase())))
            .collect(java.util.stream.Collectors.toList());
    }

    public Optional<Tournament> findById(Long id) {
        return repository.findById(id);
    }

    public Tournament save(Tournament entity) {
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(Tournament entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("name") && patch.get("name") != null) entity.setName(patch.get("name").toString());
        if (patch.containsKey("description") && patch.get("description") != null) entity.setDescription(patch.get("description").toString());
        if (patch.containsKey("status")) entity.setStatus(TournamentStatusType.valueOf(patch.get("status").toString()));
        if (patch.containsKey("format")) entity.setFormat(TournamentFormatType.valueOf(patch.get("format").toString()));
        if (patch.containsKey("tournamentType")) entity.setTournamentType(TournamentTournamentTypeType.valueOf(patch.get("tournamentType").toString()));
        if (patch.containsKey("maxPlayers") && patch.get("maxPlayers") != null) entity.setMaxPlayers(Integer.valueOf(patch.get("maxPlayers").toString()));
        if (patch.containsKey("entryFee") && patch.get("entryFee") != null) entity.setEntryFee(new java.math.BigDecimal(patch.get("entryFee").toString()));
        if (patch.containsKey("prizePool") && patch.get("prizePool") != null) entity.setPrizePool(new java.math.BigDecimal(patch.get("prizePool").toString()));
        if (patch.containsKey("startTime") && patch.get("startTime") != null) entity.setStartTime(java.time.LocalDateTime.parse(patch.get("startTime").toString()));
        if (patch.containsKey("endTime") && patch.get("endTime") != null) entity.setEndTime(java.time.LocalDateTime.parse(patch.get("endTime").toString()));
        if (patch.containsKey("isOnline") && patch.get("isOnline") != null) entity.setIsOnline(Boolean.valueOf(patch.get("isOnline").toString()));
        if (patch.containsKey("location") && patch.get("location") != null) entity.setLocation(patch.get("location").toString());
        if (patch.containsKey("rulesText") && patch.get("rulesText") != null) entity.setRulesText(patch.get("rulesText").toString());
        if (patch.containsKey("createdAt") && patch.get("createdAt") != null) entity.setCreatedAt(java.time.LocalDateTime.parse(patch.get("createdAt").toString()));
        if (patch.containsKey("seasonId") && patch.get("seasonId") != null) entity.setSeasonId(Long.valueOf(patch.get("seasonId").toString()));
        if (patch.containsKey("organizerId") && patch.get("organizerId") != null) entity.setOrganizerId(Long.valueOf(patch.get("organizerId").toString()));
    }
    private void validate(Tournament entity) {
        if (entity.getEndTime() != null && !((entity.getEndTime() == null || (entity.getStartTime() != null && entity.getEndTime().isAfter(entity.getStartTime()))))) throw new IllegalStateException("End time must be after start time");
    }

    public void start(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.start();
        repository.save(entity);
    }

    public void cancel(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.cancel();
        repository.save(entity);
    }

    public void complete(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.complete();
        repository.save(entity);
    }

    public void generateRound(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.generateRound();
        repository.save(entity);
    }

    public java.math.BigDecimal calculatePrizeDistribution(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        java.math.BigDecimal result = entity.calculatePrizeDistribution();
        repository.save(entity);
        return result;
    }

    public void registerPlayer(Long id, Integer playerId, Integer deckId) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.registerPlayer(playerId, deckId);
        repository.save(entity);
    }

    public Boolean isFull(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        Boolean result = entity.isFull();
        repository.save(entity);
        return result;
    }

    public Tournament transitionDraftToRegistration(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.assertTransition(TournamentStatusType.REGISTRATION);
        if (entity.getName() == null) {
            throw new IllegalArgumentException("name is required for Draft -> Registration");
        }
        if (entity.getStartTime() == null) {
            throw new IllegalArgumentException("start_time is required for Draft -> Registration");
        }
        entity.setStatus(TournamentStatusType.REGISTRATION);
        return repository.save(entity);
    }

    public Tournament transitionRegistrationToOngoing(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.assertTransition(TournamentStatusType.ONGOING);
        entity.setStatus(TournamentStatusType.ONGOING);
        entity.start(); // @after
        return repository.save(entity);
    }

    public Tournament transitionRegistrationToCancelled(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.assertTransition(TournamentStatusType.CANCELLED);
        entity.setStatus(TournamentStatusType.CANCELLED);
        entity.cancel(); // @after
        return repository.save(entity);
    }

    public Tournament transitionOngoingToCompleted(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.assertTransition(TournamentStatusType.COMPLETED);
        entity.setStatus(TournamentStatusType.COMPLETED);
        entity.complete(); // @after
        entity.calculatePrizeDistribution(); // @after
        return repository.save(entity);
    }

    public Tournament transitionOngoingToCancelled(Long id) {
        Tournament entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tournament not found: " + id));
        entity.assertTransition(TournamentStatusType.CANCELLED);
        entity.setStatus(TournamentStatusType.CANCELLED);
        entity.cancel(); // @after
        return repository.save(entity);
    }

    public void transitionCompletedToDraft(Long id) {
        throw new IllegalStateException("Transition Completed -> Draft is not allowed");
    }

    public void transitionCancelledToDraft(Long id) {
        throw new IllegalStateException("Transition Cancelled -> Draft is not allowed");
    }
}
