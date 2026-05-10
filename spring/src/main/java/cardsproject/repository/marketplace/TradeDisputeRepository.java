package cardsproject.repository.marketplace;

import cardsproject.domain.marketplace.TradeDispute;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TradeDisputeRepository extends JpaRepository<TradeDispute, Long> {
}
