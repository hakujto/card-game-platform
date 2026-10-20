import Vapor
import Fluent

final class DraftParticipant: Model, Content {
    static let schema = "draft_participants"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "seat_number")
    var seatNumber: Int

    @Field(key: "joined_at")
    var joinedAt: Date

    @Parent(key: "session_id")
    var session: DraftSession

    @Parent(key: "player_id")
    var player: Player

    @Children(for: \DraftPick.$participant)
    var picks: [DraftPick]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        seatNumber: Int,
        joinedAt: Date,
        sessionID: UUID,
        playerID: UUID
    ) {
        self.id = id
        self.seatNumber = seatNumber
        self.joinedAt = joinedAt
        self.$session.id = sessionID
        self.$player.id = playerID
    }

    struct DTO: Content {
        var id: UUID?
        var seatNumber: Int
        var joinedAt: Date
        var sessionId: UUID?
        var playerId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            seatNumber: self.seatNumber,
            joinedAt: self.joinedAt,
            sessionId: self.$session.id,
            playerId: self.$player.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension DraftParticipant {
    struct CreateRequest: Content {
        var seatNumber: Int
        var joinedAt: Date
        var sessionId: UUID
        var playerId: UUID
    }

    struct UpdateRequest: Content {
        var seatNumber: Int?
        var joinedAt: Date?
        var sessionId: UUID??
        var playerId: UUID??
    }
}