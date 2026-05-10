package cardsproject.repository.marketplace;

import cardsproject.domain.marketplace.Tradelisting;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TradelistingRepository extends JpaRepository<Tradelisting, Long> {
}
