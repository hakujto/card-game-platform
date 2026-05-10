package cardsproject.domain.players;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "friendships")
public class Friendship {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private FriendshipStatusType status;
    private LocalDateTime createdAt;

    @Column(name = "requester_id")
    private Long requesterId;
    @Column(name = "receiver_id")
    private Long receiverId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public FriendshipStatusType getStatus() { return status; }
    public void setStatus(FriendshipStatusType status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public Long getRequesterId() { return requesterId; }
    public void setRequesterId(Long requesterId) { this.requesterId = requesterId; }
    public Long getReceiverId() { return receiverId; }
    public void setReceiverId(Long receiverId) { this.receiverId = receiverId; }
}
