package cardsproject.service.content;

import cardsproject.domain.content.Stream;
import cardsproject.repository.content.StreamRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class StreamService {

    private final StreamRepository repository;

    public StreamService(StreamRepository repository) {
        this.repository = repository;
    }

    public List<Stream> findAll() {
        return repository.findAll();
    }

    public Optional<Stream> findById(Long id) {
        return repository.findById(id);
    }

    public Stream save(Stream entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
