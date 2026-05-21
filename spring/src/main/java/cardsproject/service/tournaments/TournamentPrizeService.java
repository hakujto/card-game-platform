package cardsproject.service.tournaments;

import cardsproject.domain.tournaments.TournamentPrize;
import cardsproject.repository.tournaments.TournamentPrizeRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.tournaments.TournamentPrizePrizeTypeType;

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

    public void applyPatch(TournamentPrize entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("placementFrom") && patch.get("placementFrom") != null) entity.setPlacementFrom(Integer.valueOf(patch.get("placementFrom").toString()));
        if (patch.containsKey("placementTo") && patch.get("placementTo") != null) entity.setPlacementTo(Integer.valueOf(patch.get("placementTo").toString()));
        if (patch.containsKey("prizeType")) entity.setPrizeType(TournamentPrizePrizeTypeType.valueOf(patch.get("prizeType").toString()));
        if (patch.containsKey("amount") && patch.get("amount") != null) entity.setAmount(new java.math.BigDecimal(patch.get("amount").toString()));
        if (patch.containsKey("description") && patch.get("description") != null) entity.setDescription(patch.get("description").toString());
        if (patch.containsKey("packsCount") && patch.get("packsCount") != null) entity.setPacksCount(Integer.valueOf(patch.get("packsCount").toString()));
        if (patch.containsKey("seasonPoints") && patch.get("seasonPoints") != null) entity.setSeasonPoints(Integer.valueOf(patch.get("seasonPoints").toString()));
        if (patch.containsKey("tournamentId") && patch.get("tournamentId") != null) entity.setTournamentId(Long.valueOf(patch.get("tournamentId").toString()));
    }

    public Boolean appliesToPlacement(Long id, Integer placement) {
        TournamentPrize entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TournamentPrize not found: " + id));
        Boolean result = entity.appliesToPlacement(placement);
        repository.save(entity);
        return result;
    }

    public void awardToPlayer(Long id, Integer playerId) {
        TournamentPrize entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TournamentPrize not found: " + id));
        entity.awardToPlayer(playerId);
        repository.save(entity);
    }
}
