package cardsproject.repository.marketplace;

import cardsproject.domain.marketplace.TradeBid;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TradeBidRepository extends JpaRepository<TradeBid, Long> {
}
