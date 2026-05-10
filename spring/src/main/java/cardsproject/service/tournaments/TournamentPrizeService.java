package cardsproject.service.tournaments;

import cardsproject.domain.tournaments.TournamentPrize;
import cardsproject.repository.tournaments.TournamentPrizeRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class TournamentPrizeService {

    private final TournamentPrizeRepository repository;

    public TournamentPrizeService(TournamentPrizeRepository repository) {
        this.repository = repository;
    }

    public List<TournamentPrize> findAll() {
        return repository.findAll();
    }

    public Optional<TournamentPrize> findById(Long id) {
        return repository.findById(id);
    }

    public TournamentPrize save(TournamentPrize entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
