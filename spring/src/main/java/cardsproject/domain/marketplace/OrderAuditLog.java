package cardsproject.domain.marketplace;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "orders_audit_log")
public class OrderAuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "record_id", nullable = false)
    private Long recordId;

    @Column(name = "field", nullable = false, length = 100)
    private String field;

    @Column(name = "old_value", columnDefinition = "TEXT")
    private String oldValue;

    @Column(name = "new_value", columnDefinition = "TEXT")
    private String newValue;

    @Column(name = "changed_at")
    private LocalDateTime changedAt = LocalDateTime.now();

    // getters/setters omitted — use Lombok @Data or generate in IDE
}
