package cardsproject.service.content;

import cardsproject.domain.content.Stream;
import cardsproject.repository.content.StreamRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.content.StreamStatusType;
import cardsproject.domain.content.StreamPlatformType;
import cardsproject.domain.content.StreamLanguageType;

@Service
public class StreamService {

    private final StreamRepository repository;

    public StreamService(StreamRepository repository) {
        this.repository = repository;
    }

    public List<Stream> findAll() {
        return repository.findAll();
    }

    public List<Stream> search(String q) {
        if (q == null || q.isBlank()) return repository.findAll();
        return repository.findAll().stream()
            .filter(e -> (e.getTitle() != null && e.getTitle().toLowerCase().contains(q.toLowerCase())))
            .collect(java.util.stream.Collectors.toList());
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

    public void applyPatch(Stream entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("title") && patch.get("title") != null) entity.setTitle(patch.get("title").toString());
        if (patch.containsKey("streamUrl") && patch.get("streamUrl") != null) entity.setStreamUrl(patch.get("streamUrl").toString());
        if (patch.containsKey("status")) entity.setStatus(StreamStatusType.valueOf(patch.get("status").toString()));
        if (patch.containsKey("platform")) entity.setPlatform(StreamPlatformType.valueOf(patch.get("platform").toString()));
        if (patch.containsKey("language")) entity.setLanguage(StreamLanguageType.valueOf(patch.get("language").toString()));
        if (patch.containsKey("isOfficial") && patch.get("isOfficial") != null) entity.setIsOfficial(Boolean.valueOf(patch.get("isOfficial").toString()));
        if (patch.containsKey("viewerCountPeak") && patch.get("viewerCountPeak") != null) entity.setViewerCountPeak(Integer.valueOf(patch.get("viewerCountPeak").toString()));
        if (patch.containsKey("scheduledStart") && patch.get("scheduledStart") != null) entity.setScheduledStart(java.time.LocalDateTime.parse(patch.get("scheduledStart").toString()));
        if (patch.containsKey("actualStart") && patch.get("actualStart") != null) entity.setActualStart(java.time.LocalDateTime.parse(patch.get("actualStart").toString()));
        if (patch.containsKey("endedAt") && patch.get("endedAt") != null) entity.setEndedAt(java.time.LocalDateTime.parse(patch.get("endedAt").toString()));
        if (patch.containsKey("vodUrl") && patch.get("vodUrl") != null) entity.setVodUrl(patch.get("vodUrl").toString());
        if (patch.containsKey("tournamentId") && patch.get("tournamentId") != null) entity.setTournamentId(Long.valueOf(patch.get("tournamentId").toString()));
        if (patch.containsKey("streamerId") && patch.get("streamerId") != null) entity.setStreamerId(Long.valueOf(patch.get("streamerId").toString()));
    }
    private void validate(Stream entity) {
        if (entity.getActualStart() != null && !(StreamStatusType.LIVE.equals(entity.getStatus()))) throw new IllegalStateException("actual_start_requires_live_or_ended");
        if (entity.getEndedAt() != null && !(StreamStatusType.ENDED.equals(entity.getStatus()))) throw new IllegalStateException("ended_at can only be set when stream status is Ended");
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

    public Integer durationMinutes(Long id) {
        Stream entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Stream not found: " + id));
        Integer result = entity.durationMinutes();
        repository.save(entity);
        return result;
    }

    public Stream transitionScheduledToLive(Long id) {
        Stream entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Stream not found: " + id));
        entity.assertTransition(StreamStatusType.LIVE);
        if (entity.getStreamUrl() == null) {
            throw new IllegalArgumentException("stream_url is required for Scheduled -> Live");
        }
        entity.setStatus(StreamStatusType.LIVE);
        entity.goLive(); // @after
        return repository.save(entity);
    }

    public Stream transitionLiveToEnded(Long id) {
        Stream entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Stream not found: " + id));
        entity.assertTransition(StreamStatusType.ENDED);
        entity.setStatus(StreamStatusType.ENDED);
        entity.end(); // @after
        return repository.save(entity);
    }

    public void transitionEndedToLive(Long id) {
        throw new IllegalStateException("Transition Ended -> Live is not allowed");
    }
}
