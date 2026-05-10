package cardsproject.repository.content;

import cardsproject.domain.content.ArticleTagAssignment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ArticleTagAssignmentRepository extends JpaRepository<ArticleTagAssignment, Long> {
}
