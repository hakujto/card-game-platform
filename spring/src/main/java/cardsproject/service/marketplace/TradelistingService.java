package cardsproject.service.marketplace;

import cardsproject.domain.marketplace.Tradelisting;
import cardsproject.repository.marketplace.TradelistingRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.marketplace.TradelistingStatusType;
import cardsproject.domain.marketplace.TradelistingListingTypeType;

@Service
public class TradelistingService {

    private final TradelistingRepository repository;

    public TradelistingService(TradelistingRepository repository) {
        this.repository = repository;
    }

    public List<Tradelisting> findAll() {
        return repository.findAll();
    }

    public Optional<Tradelisting> findById(Long id) {
        return repository.findById(id);
    }

    public Tradelisting save(Tradelisting entity) {
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
    private void validate(Tradelisting entity) {
        if (TradelistingListingTypeType.FIXEDPRICE.equals(entity.getListingType()) && entity.getAskingPrice() == null) throw new IllegalStateException("Fixed price listing must have an asking price");
        if (TradelistingListingTypeType.AUCTION.equals(entity.getListingType()) && !(entity.getAuctionStartPrice() != null && entity.getAuctionEndTime() != null)) throw new IllegalStateException("Auction listing must have a start price and end time");
    }

    public void close(Long id) {
        Tradelisting entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tradelisting not found: " + id));
        entity.close();
        repository.save(entity);
    }

    public void extend(Long id, Integer days) {
        Tradelisting entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tradelisting not found: " + id));
        entity.extend(days);
        repository.save(entity);
    }

    public void cancel(Long id) {
        Tradelisting entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tradelisting not found: " + id));
        entity.cancel();
        repository.save(entity);
    }

    // triggered by @on(status = Sold)
    public void setStatus(Long id, TradelistingStatusType status) {
        Tradelisting entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Tradelisting not found: " + id));
        entity.setStatus(status);
        if (status == TradelistingStatusType.SOLD) {
            entity.finalizeAuction();
        }
        repository.save(entity);
    }
}
