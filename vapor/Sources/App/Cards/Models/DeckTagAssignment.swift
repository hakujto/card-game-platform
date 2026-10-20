import Vapor
import Fluent

final class DeckTagAssignment: Model, Content {
    static let schema = "deck_tag_assignments"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "deck_id")
    var deck: Deck

    @Parent(key: "tag_id")
    var tag: DeckTag

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        deckID: UUID,
        tagID: UUID
    ) {
        self.id = id
        self.$deck.id = deckID
        self.$tag.id = tagID
    }

    struct DTO: Content {
        var id: UUID?
        var deckId: UUID?
        var tagId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            deckId: self.$deck.id,
            tagId: self.$tag.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension DeckTagAssignment {
    struct CreateRequest: Content {
        var deckId: UUID
        var tagId: UUID
    }

    struct UpdateRequest: Content {
        var deckId: UUID??
        var tagId: UUID??
    }
}