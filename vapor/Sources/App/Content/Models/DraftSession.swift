import Vapor
import Fluent

enum DraftSessionStatus: String, Codable, CaseIterable {
    case waitingForPlayers = "WaitingForPlayers"
    case drafting = "Drafting"
    case completed = "Completed"
    case abandoned = "Abandoned"
}

enum DraftSessionDraftType: String, Codable, CaseIterable {
    case booster = "Booster"
    case cube = "Cube"
    case rochester = "Rochester"
}

final class DraftSession: Model, Content {
    static let schema = "draft_sessions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "status")
    var status: DraftSessionStatus

    @Field(key: "draft_type")
    var draftType: DraftSessionDraftType

    @OptionalField(key: "pack_contents")
    var packContents: String?

    @Field(key: "seats")
    var seats: Int

    @Field(key: "time_per_pick_seconds")
    var timePerPickSeconds: Int

    @OptionalField(key: "completed_at")
    var completedAt: Date?

    @Parent(key: "card_set_id")
    var cardSet: CardSet

    @Children(for: \DraftParticipant.$session)
    var participants: [DraftParticipant]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        status: DraftSessionStatus = .waitingForPlayers,
        draftType: DraftSessionDraftType = .booster,
        packContents: String?,
        seats: Int = 8,
        timePerPickSeconds: Int = 30,
        completedAt: Date?,
        cardSetID: UUID
    ) {
        self.id = id
        self.status = status
        self.draftType = draftType
        self.packContents = packContents
        self.seats = seats
        self.timePerPickSeconds = timePerPickSeconds
        self.completedAt = completedAt
        self.$cardSet.id = cardSetID
    }

    struct DTO: Content {
        var id: UUID?
        var status: DraftSessionStatus
        var draftType: DraftSessionDraftType
        var packContents: String?
        var seats: Int
        var timePerPickSeconds: Int
        var completedAt: Date?
        var cardSetId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            status: self.status,
            draftType: self.draftType,
            packContents: self.packContents,
            seats: self.seats,
            timePerPickSeconds: self.timePerPickSeconds,
            completedAt: self.completedAt,
            cardSetId: self.$cardSet.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension DraftSession {
    struct CreateRequest: Content {
        var status: DraftSessionStatus = .waitingForPlayers
        var draftType: DraftSessionDraftType = .booster
        var packContents: String?
        var seats: Int = 8
        var timePerPickSeconds: Int = 30
        var completedAt: Date?
        var cardSetId: UUID
    }

    struct UpdateRequest: Content {
        var status: DraftSessionStatus?
        var draftType: DraftSessionDraftType?
        var packContents: String??
        var seats: Int?
        var timePerPickSeconds: Int?
        var completedAt: Date??
        var cardSetId: UUID??
    }
}