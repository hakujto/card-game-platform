package cardsproject.service.cards;

import cardsproject.domain.cards.CardRuling;
import cardsproject.repository.cards.CardRulingRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class CardRulingService {

    private final CardRulingRepository repository;

    public CardRulingService(CardRulingRepository repository) {
        this.repository = repository;
    }

    public List<CardRuling> findAll() {
        return repository.findAll();
    }

    public Optional<CardRuling> findById(Long id) {
        return repository.findById(id);
    }

    public CardRuling save(CardRuling entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
