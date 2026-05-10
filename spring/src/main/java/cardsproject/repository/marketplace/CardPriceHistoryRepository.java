package cardsproject.repository.marketplace;

import cardsproject.domain.marketplace.CardPriceHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CardPriceHistoryRepository extends JpaRepository<CardPriceHistory, Long> {
}
