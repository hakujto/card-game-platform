import Vapor
import Fluent

final class DraftPick: Model, Content {
    static let schema = "draft_picks"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "pick_number")
    var pickNumber: Int

    @Field(key: "pack_number")
    var packNumber: Int

    @Field(key: "picked_at")
    var pickedAt: Date

    @Parent(key: "participant_id")
    var participant: DraftParticipant

    @Parent(key: "card_id")
    var card: Card

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        pickNumber: Int,
        packNumber: Int,
        pickedAt: Date,
        participantID: UUID,
        cardID: UUID
    ) {
        self.id = id
        self.pickNumber = pickNumber
        self.packNumber = packNumber
        self.pickedAt = pickedAt
        self.$participant.id = participantID
        self.$card.id = cardID
    }

    struct DTO: Content {
        var id: UUID?
        var pickNumber: Int
        var packNumber: Int
        var pickedAt: Date
        var participantId: UUID?
        var cardId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            pickNumber: self.pickNumber,
            packNumber: self.packNumber,
            pickedAt: self.pickedAt,
            participantId: self.$participant.id,
            cardId: self.$card.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension DraftPick {
    struct CreateRequest: Content {
        var pickNumber: Int
        var packNumber: Int
        var pickedAt: Date
        var participantId: UUID
        var cardId: UUID
    }

    struct UpdateRequest: Content {
        var pickNumber: Int?
        var packNumber: Int?
        var pickedAt: Date?
        var participantId: UUID??
        var cardId: UUID??
    }
}