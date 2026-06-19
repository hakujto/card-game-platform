package cardsproject.service.marketplace;

import cardsproject.domain.marketplace.TradeListing;
import cardsproject.repository.marketplace.TradeListingRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.marketplace.TradeListingStatusType;
import cardsproject.domain.marketplace.TradeListingListingTypeType;
import cardsproject.domain.marketplace.TradeListingConditionType;

@Service
public class TradeListingService {

    private final TradeListingRepository repository;

    public TradeListingService(TradeListingRepository repository) {
        this.repository = repository;
    }

    public List<TradeListing> findAll() {
        return repository.findAll();
    }

    public List<TradeListing> search(String q) {
        if (q == null || q.isBlank()) return repository.findAll();
        return repository.findAll().stream()
            .filter(e -> (e.getDescription() != null && e.getDescription().toLowerCase().contains(q.toLowerCase())))
            .collect(java.util.stream.Collectors.toList());
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

    public void applyPatch(TradeListing entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("status")) entity.setStatus(TradeListingStatusType.valueOf(patch.get("status").toString()));
        if (patch.containsKey("listingType")) entity.setListingType(TradeListingListingTypeType.valueOf(patch.get("listingType").toString()));
        if (patch.containsKey("askingPrice") && patch.get("askingPrice") != null) entity.setAskingPrice(new java.math.BigDecimal(patch.get("askingPrice").toString()));
        if (patch.containsKey("auctionStartPrice") && patch.get("auctionStartPrice") != null) entity.setAuctionStartPrice(new java.math.BigDecimal(patch.get("auctionStartPrice").toString()));
        if (patch.containsKey("auctionCurrentBid") && patch.get("auctionCurrentBid") != null) entity.setAuctionCurrentBid(new java.math.BigDecimal(patch.get("auctionCurrentBid").toString()));
        if (patch.containsKey("auctionEndTime") && patch.get("auctionEndTime") != null) entity.setAuctionEndTime(java.time.LocalDateTime.parse(patch.get("auctionEndTime").toString()));
        if (patch.containsKey("foil") && patch.get("foil") != null) entity.setFoil(Boolean.valueOf(patch.get("foil").toString()));
        if (patch.containsKey("condition")) entity.setCondition(TradeListingConditionType.valueOf(patch.get("condition").toString()));
        if (patch.containsKey("quantity") && patch.get("quantity") != null) entity.setQuantity(Integer.valueOf(patch.get("quantity").toString()));
        if (patch.containsKey("description") && patch.get("description") != null) entity.setDescription(patch.get("description").toString());
        if (patch.containsKey("createdAt") && patch.get("createdAt") != null) entity.setCreatedAt(java.time.LocalDateTime.parse(patch.get("createdAt").toString()));
        if (patch.containsKey("expiresAt") && patch.get("expiresAt") != null) entity.setExpiresAt(java.time.LocalDateTime.parse(patch.get("expiresAt").toString()));
        if (patch.containsKey("sellerId") && patch.get("sellerId") != null) entity.setSellerId(Long.valueOf(patch.get("sellerId").toString()));
        if (patch.containsKey("cardId") && patch.get("cardId") != null) entity.setCardId(Long.valueOf(patch.get("cardId").toString()));
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
        if (!(TradeListingStatusType.ACTIVE.equals(entity.getStatus())))
            throw new IllegalStateException("Guard condition not met for cancel");
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

    public TradeListing transitionPendingToActive(Long id) {
        TradeListing entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeListing not found: " + id));
        entity.assertTransition(TradeListingStatusType.ACTIVE);
        if (entity.getQuantity() == null) {
            throw new IllegalArgumentException("quantity is required for Pending -> Active");
        }
        entity.setStatus(TradeListingStatusType.ACTIVE);
        return repository.save(entity);
    }

    public TradeListing transitionActiveToSold(Long id) {
        TradeListing entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeListing not found: " + id));
        entity.assertTransition(TradeListingStatusType.SOLD);
        entity.setStatus(TradeListingStatusType.SOLD);
        entity.finalizeAuction(); // @after
        return repository.save(entity);
    }

    public TradeListing transitionActiveToExpired(Long id) {
        TradeListing entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeListing not found: " + id));
        entity.assertTransition(TradeListingStatusType.EXPIRED);
        entity.setStatus(TradeListingStatusType.EXPIRED);
        entity.close(); // @after
        return repository.save(entity);
    }

    public TradeListing transitionActiveToCancelled(Long id) {
        TradeListing entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("TradeListing not found: " + id));
        entity.assertTransition(TradeListingStatusType.CANCELLED);
        entity.setStatus(TradeListingStatusType.CANCELLED);
        entity.cancel(); // @after
        return repository.save(entity);
    }

    public void transitionSoldToActive(Long id) {
        throw new IllegalStateException("Transition Sold -> Active is not allowed");
    }

    public void transitionExpiredToActive(Long id) {
        throw new IllegalStateException("Transition Expired -> Active is not allowed");
    }
}
