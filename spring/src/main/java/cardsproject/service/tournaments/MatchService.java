package cardsproject.service.tournaments;

import cardsproject.domain.tournaments.Match;
import cardsproject.repository.tournaments.MatchRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

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
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
