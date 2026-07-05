package cardsproject.service.players;

import cardsproject.domain.players.Player;
import cardsproject.repository.players.PlayerRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.players.PlayerRankType;
import cardsproject.domain.players.PlayerPreferredFormatType;

@Service
public class PlayerService {

    private final PlayerRepository repository;

    public PlayerService(PlayerRepository repository) {
        this.repository = repository;
    }

    public List<Player> findAll() {
        return repository.findAll();
    }

    public List<Player> search(String q) {
        if (q == null || q.isBlank()) return repository.findAll();
        return repository.findAll().stream()
            .filter(e -> (e.getDisplayName() != null && e.getDisplayName().toLowerCase().contains(q.toLowerCase())))
            .collect(java.util.stream.Collectors.toList());
    }

    public Optional<Player> findById(Long id) {
        return repository.findById(id);
    }

    public Player save(Player entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void applyPatch(Player entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("publicId") && patch.get("publicId") != null) entity.setPublicId(java.util.UUID.fromString(patch.get("publicId").toString()));
        if (patch.containsKey("displayName") && patch.get("displayName") != null) entity.setDisplayName(patch.get("displayName").toString());
        if (patch.containsKey("rank")) entity.setRank(PlayerRankType.valueOf(patch.get("rank").toString()));
        if (patch.containsKey("rating") && patch.get("rating") != null) entity.setRating(Integer.valueOf(patch.get("rating").toString()));
        if (patch.containsKey("peakRating") && patch.get("peakRating") != null) entity.setPeakRating(Integer.valueOf(patch.get("peakRating").toString()));
        if (patch.containsKey("bio") && patch.get("bio") != null) entity.setBio(patch.get("bio").toString());
        if (patch.containsKey("countryCode") && patch.get("countryCode") != null) entity.setCountryCode(patch.get("countryCode").toString());
        if (patch.containsKey("avatarUrl") && patch.get("avatarUrl") != null) entity.setAvatarUrl(patch.get("avatarUrl").toString());
        if (patch.containsKey("preferredFormat")) entity.setPreferredFormat(PlayerPreferredFormatType.valueOf(patch.get("preferredFormat").toString()));
        if (patch.containsKey("contactEmail") && patch.get("contactEmail") != null) entity.setContactEmail(patch.get("contactEmail").toString());
        if (patch.containsKey("winRateCached") && patch.get("winRateCached") != null) entity.setWinRateCached(Double.valueOf(patch.get("winRateCached").toString()));
        if (patch.containsKey("isVerified") && patch.get("isVerified") != null) entity.setIsVerified(Boolean.valueOf(patch.get("isVerified").toString()));
        if (patch.containsKey("createdAt") && patch.get("createdAt") != null) entity.setCreatedAt(java.time.LocalDateTime.parse(patch.get("createdAt").toString()));
        if (patch.containsKey("lastActiveAt") && patch.get("lastActiveAt") != null) entity.setLastActiveAt(java.time.LocalDateTime.parse(patch.get("lastActiveAt").toString()));
        if (patch.containsKey("userId") && patch.get("userId") != null) entity.setUserId(Long.valueOf(patch.get("userId").toString()));
    }

    public Boolean promote(Long id) {
        Player entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Player not found: " + id));
        Boolean result = entity.promote();
        repository.save(entity);
        return result;
    }

    public Boolean demote(Long id) {
        Player entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Player not found: " + id));
        Boolean result = entity.demote();
        repository.save(entity);
        return result;
    }

    public void recordWin(Long id) {
        Player entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Player not found: " + id));
        entity.recordWin();
        repository.save(entity);
    }

    public void recordLoss(Long id) {
        Player entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Player not found: " + id));
        entity.recordLoss();
        repository.save(entity);
    }

    public java.math.BigDecimal winRate(Long id) {
        Player entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Player not found: " + id));
        java.math.BigDecimal result = entity.winRate();
        repository.save(entity);
        return result;
    }

    public void verify(Long id) {
        Player entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Player not found: " + id));
        entity.verify();
        repository.save(entity);
    }

    public void updateRating(Long id, Integer delta) {
        Player entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Player not found: " + id));
        entity.updateRating(delta);
        repository.save(entity);
    }
}
