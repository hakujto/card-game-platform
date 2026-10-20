import Vapor
import Fluent

enum FriendshipStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case accepted = "Accepted"
    case blocked = "Blocked"
}

final class Friendship: Model, Content {
    static let schema = "friendships"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "status")
    var status: FriendshipStatus

    @Parent(key: "requester_id")
    var requester: Player

    @Parent(key: "receiver_id")
    var receiver: Player

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        status: FriendshipStatus = .pending,
        requesterID: UUID,
        receiverID: UUID
    ) {
        self.id = id
        self.status = status
        self.$requester.id = requesterID
        self.$receiver.id = receiverID
    }

    struct DTO: Content {
        var id: UUID?
        var status: FriendshipStatus
        var requesterId: UUID?
        var receiverId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            status: self.status,
            requesterId: self.$requester.id,
            receiverId: self.$receiver.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension Friendship {
    struct CreateRequest: Content {
        var status: FriendshipStatus = .pending
        var requesterId: UUID
        var receiverId: UUID
    }

    struct UpdateRequest: Content {
        var status: FriendshipStatus?
        var requesterId: UUID??
        var receiverId: UUID??
    }
}