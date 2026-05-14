package cardsproject.service.content;

import cardsproject.domain.content.Stream;
import cardsproject.repository.content.StreamRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.content.StreamStatusType;

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
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
    private void validate(Stream entity) {
        if (entity.getActualStart() != null && !(StreamStatusType.LIVE.equals(entity.getStatus()))) throw new IllegalStateException("actual_start_requires_live_or_ended");
    }

    public void goLive(Long id) {
        Stream entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Stream not found: " + id));
        entity.goLive();
        repository.save(entity);
    }

    public void end(Long id) {
        Stream entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Stream not found: " + id));
        entity.end();
        repository.save(entity);
    }

    public void updateViewerPeak(Long id, Integer count) {
        Stream entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Stream not found: " + id));
        entity.updateViewerPeak(count);
        repository.save(entity);
    }
}
