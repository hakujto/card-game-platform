package cardsproject.service.tournaments;

import cardsproject.domain.tournaments.Tournament;
import cardsproject.repository.tournaments.TournamentRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class TournamentService {

    private final TournamentRepository repository;

    public TournamentService(TournamentRepository repository) {
        this.repository = repository;
    }

    public List<Tournament> findAll() {
        return repository.findAll();
    }

    public Optional<Tournament> findById(Long id) {
        return repository.findById(id);
    }

    public Tournament save(Tournament entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
