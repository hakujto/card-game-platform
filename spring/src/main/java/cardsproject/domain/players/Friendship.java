package cardsproject.domain.players;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

@Entity
@Table(name = "friendships")
public class Friendship {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private FriendshipStatusType status;
    private LocalDateTime createdAt;

    // @ManyToOne -> Player, onDelete=CASCADE, relatedName=sent_friend_requests
    @Column(name = "requester_id")
    private Long requesterId;
    // @ManyToOne -> Player, onDelete=CASCADE, relatedName=received_friend_requests
    @Column(name = "receiver_id")
    private Long receiverId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public FriendshipStatusType getStatus() { return status; }
    public void setStatus(FriendshipStatusType status) { this.status = status; }
    @JsonProperty("createdAt")
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public Long getRequesterId() { return requesterId; }
    public void setRequesterId(Long requesterId) { this.requesterId = requesterId; }
    public Long getReceiverId() { return receiverId; }
    public void setReceiverId(Long receiverId) { this.receiverId = receiverId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void accept() {
        // TODO: implement accept
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void decline() {
        // TODO: implement decline
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void block() {
        // TODO: implement block
    }
}
