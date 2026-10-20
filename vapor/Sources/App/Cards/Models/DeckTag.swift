import Vapor
import Fluent

final class DeckTag: Model, Content {
    static let schema = "deck_tags"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @OptionalField(key: "slug")
    var slug: String?

    @OptionalField(key: "color")
    var color: String?

    @Children(for: \DeckTagAssignment.$tag)
    var deckAssignments: [DeckTagAssignment]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        name: String,
        slug: String?,
        color: String?
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.color = color
    }

    struct DTO: Content {
        var id: UUID?
        var name: String
        var slug: String?
        var color: String?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            name: self.name,
            slug: self.slug,
            color: self.color,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension DeckTag {
    struct CreateRequest: Content {
        var name: String
        var slug: String?
        var color: String?
    }

    struct UpdateRequest: Content {
        var name: String?
        var slug: String??
        var color: String??
    }
}