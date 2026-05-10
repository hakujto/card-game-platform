package cardsproject.service.tournaments;

import cardsproject.domain.tournaments.TournamentRegistration;
import cardsproject.repository.tournaments.TournamentRegistrationRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class TournamentRegistrationService {

    private final TournamentRegistrationRepository repository;

    public TournamentRegistrationService(TournamentRegistrationRepository repository) {
        this.repository = repository;
    }

    public List<TournamentRegistration> findAll() {
        return repository.findAll();
    }

    public Optional<TournamentRegistration> findById(Long id) {
        return repository.findById(id);
    }

    public TournamentRegistration save(TournamentRegistration entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
