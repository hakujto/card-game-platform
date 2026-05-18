package cardsproject.repository.marketplace;

import cardsproject.domain.marketplace.TradeListing;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TradeListingRepository extends JpaRepository<TradeListing, Long> {
}
