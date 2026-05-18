package cardsproject.service.marketplace;

import cardsproject.domain.marketplace.TradeListing;
import cardsproject.repository.marketplace.TradeListingRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.marketplace.TradeListingStatusType;
import cardsproject.domain.marketplace.TradeListingListingTypeType;

@Service
public class TradeListingService {

    private final TradeListingRepository repository;

    public TradeListingService(TradeListingRepository repository) {
        this.repository = repository;
    }

    public List<TradeListing> findAll() {
        return repository.findAll();
    }

    public Optional<TradeListing> findById(Long id) {
        return repository.findById(id);
    }

    public TradeListing save(TradeListing entity) {
        validate(entity);
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
    private void validate(TradeListing entity) {
        if (TradeListingListingTypeType.FIXEDPRICE.equals(entity.getListingType()) && entity.getAskingPrice() == null) throw new IllegalStateException("Fixed price listing must have an asking price");
        if (TradeListingListingTypeType.AUCTION.equals(entity.getListingType()) && !(entity.getAuctionStartPrice() != null && entity.getAuctionEndTime() != null)) throw new IllegalStateException("Auction listing must have a start price and end time");
    }

    public void close(Long id) {
        TradeListing entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeListing not found: " + id));
        entity.close();
        repository.save(entity);
    }

    public void extend(Long id, Integer days) {
        TradeListing entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeListing not found: " + id));
        entity.extend(days);
        repository.save(entity);
    }

    public void cancel(Long id) {
        TradeListing entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeListing not found: " + id));
        entity.cancel();
        repository.save(entity);
    }

    public Boolean isExpired(Long id) {
        TradeListing entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeListing not found: " + id));
        Boolean result = entity.isExpired();
        repository.save(entity);
        return result;
    }

    public void finalizeAuction(Long id) {
        TradeListing entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeListing not found: " + id));
        entity.finalizeAuction();
        repository.save(entity);
    }

    // triggered by @on(status = Sold)
    public void setStatus(Long id, TradeListingStatusType status) {
        TradeListing entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeListing not found: " + id));
        entity.setStatus(status);
        if (status == TradeListingStatusType.SOLD) {
            entity.finalizeAuction();
        }
        repository.save(entity);
    }
}
