package cardsproject.service.tournaments;

import cardsproject.domain.tournaments.Match;
import cardsproject.repository.tournaments.MatchRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.tournaments.MatchStatusType;

@Service
public class MatchService {

    private final MatchRepository repository;

    public MatchService(MatchRepository repository) {
        this.repository = repository;
    }

    public List<Match> findAll() {
        return repository.findAll();
    }

    public Optional<Match> findById(Long id) {
        return repository.findById(id);
    }

    public Match save(Match entity) {
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
    private void validate(Match entity) {
        if (MatchStatusType.BYE.equals(entity.getStatus()) && entity.getPlayer2Id() != null) throw new IllegalStateException("BYE match must not have a second player");
    }

    public void recordResult(Long id, Integer p1Wins, Integer p2Wins) {
        Match entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Match not found: " + id));
        entity.recordResult(p1Wins, p2Wins);
        entity.determineWinner(); // @after
        repository.save(entity);
    }

    public Boolean determineWinner(Long id) {
        Match entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Match not found: " + id));
        Boolean result = entity.determineWinner();
        repository.save(entity);
        return result;
    }

    public void draw(Long id) {
        Match entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Match not found: " + id));
        entity.draw();
        repository.save(entity);
    }
}
